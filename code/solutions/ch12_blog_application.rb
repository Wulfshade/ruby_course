#!/usr/bin/env ruby
# Chapter 12: Mini Project - Blog Application (Sinatra Version)

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'bcrypt'
require 'erb'
require 'time'

# Configuration
set :port, 4567
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'
enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || 'super_secret_key_for_development'

# Database setup
def db
  @db ||= SQLite3::Database.new("blog.db")
  @db.results_as_hash = true
  @db
end

# Initialize database tables if they don't exist
def init_db
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password_digest TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      user_id INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL,
      post_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (post_id) REFERENCES posts (id),
      FOREIGN KEY (user_id) REFERENCES users (id)
    );
  SQL
end

# Initialize the database when the application starts
init_db

# Helpers
helpers do
  def logged_in?
    session[:user_id] != nil
  end
  
  def current_user
    if logged_in?
      @current_user ||= db.execute("SELECT id, username, email FROM users WHERE id = ?", session[:user_id]).first
    end
  end
  
  def require_login
    redirect '/login' unless logged_in?
  end
  
  def h(text)
    Rack::Utils.escape_html(text)
  end
  
  def format_date(date_string)
    return "" unless date_string
    date = Time.parse(date_string)
    date.strftime("%B %d, %Y at %I:%M %p")
  end
end

# Routes

# Home page - show recent posts
get '/' do
  @posts = db.execute("SELECT posts.*, users.username FROM posts JOIN users ON posts.user_id = users.id ORDER BY created_at DESC LIMIT 10")
  erb :index
end

# User authentication routes
get '/login' do
  redirect '/' if logged_in?
  erb :login
end

post '/login' do
  username = params[:username]
  password = params[:password]
  
  user = db.execute("SELECT * FROM users WHERE username = ?", username).first
  
  if user && BCrypt::Password.new(user["password_digest"]) == password
    session[:user_id] = user["id"]
    redirect '/'
  else
    @error = "Invalid username or password"
    erb :login
  end
end

get '/signup' do
  redirect '/' if logged_in?
  erb :signup
end

post '/signup' do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  password_confirmation = params[:password_confirmation]
  
  if password != password_confirmation
    @error = "Passwords don't match"
    return erb :signup
  end
  
  begin
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, email, password_digest) VALUES (?, ?, ?)", 
               [username, email, password_digest])
    
    user = db.execute("SELECT * FROM users WHERE username = ?", username).first
    session[:user_id] = user["id"]
    redirect '/'
  rescue SQLite3::ConstraintException
    @error = "Username or email already taken"
    erb :signup
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

# Blog post routes
get '/posts/new' do
  require_login
  erb :new_post
end

post '/posts' do
  require_login
  title = params[:title]
  content = params[:content]
  
  if title.empty? || content.empty?
    @error = "Title and content are required"
    return erb :new_post
  end
  
  db.execute("INSERT INTO posts (title, content, user_id) VALUES (?, ?, ?)",
             [title, content, session[:user_id]])
  
  redirect '/'
end

get '/posts/:id' do
  @post = db.execute("SELECT posts.*, users.username FROM posts JOIN users ON posts.user_id = users.id WHERE posts.id = ?", params[:id]).first
  
  if @post
    @comments = db.execute("SELECT comments.*, users.username FROM comments JOIN users ON comments.user_id = users.id WHERE post_id = ? ORDER BY created_at", params[:id])
    erb :show_post
  else
    status 404
    "Post not found"
  end
end

get '/posts/:id/edit' do
  require_login
  @post = db.execute("SELECT * FROM posts WHERE id = ?", params[:id]).first
  
  if @post && @post["user_id"] == session[:user_id]
    erb :edit_post
  else
    redirect '/'
  end
end

post '/posts/:id' do
  require_login
  @post = db.execute("SELECT * FROM posts WHERE id = ?", params[:id]).first
  
  if @post && @post["user_id"] == session[:user_id]
    title = params[:title]
    content = params[:content]
    
    if title.empty? || content.empty?
      @error = "Title and content are required"
      return erb :edit_post
    end
    
    db.execute("UPDATE posts SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
               [title, content, params[:id]])
    
    redirect "/posts/#{params[:id]}"
  else
    redirect '/'
  end
end

post '/posts/:id/delete' do
  require_login
  @post = db.execute("SELECT * FROM posts WHERE id = ?", params[:id]).first
  
  if @post && @post["user_id"] == session[:user_id]
    # Delete associated comments first
    db.execute("DELETE FROM comments WHERE post_id = ?", params[:id])
    # Then delete the post
    db.execute("DELETE FROM posts WHERE id = ?", params[:id])
  end
  
  redirect '/'
end

# Comment routes
post '/posts/:id/comments' do
  require_login
  content = params[:content]
  post_id = params[:id]
  
  if content.empty?
    redirect "/posts/#{post_id}"
  end
  
  db.execute("INSERT INTO comments (content, post_id, user_id) VALUES (?, ?, ?)",
             [content, post_id, session[:user_id]])
  
  redirect "/posts/#{post_id}"
end

# Example HTML templates (in a real application, these would be in separate .erb files)

__END__

@@ layout
<!DOCTYPE html>
<html>
<head>
  <title>Ruby Blog</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 0;
      padding: 0;
      color: #333;
    }
    
    .container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    
    header {
      background-color: #cc342d;
      color: white;
      padding: 10px 0;
    }
    
    header .container {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    header h1 {
      margin: 0;
    }
    
    nav a {
      color: white;
      text-decoration: none;
      margin-left: 15px;
    }
    
    .post {
      border-bottom: 1px solid #ddd;
      padding: 20px 0;
    }
    
    .post h2 {
      margin-top: 0;
    }
    
    .post-meta {
      color: #666;
      font-size: 0.9em;
    }
    
    .comment {
      margin: 20px 0;
      padding: 10px;
      background-color: #f9f9f9;
      border-radius: 5px;
    }
    
    .comment-meta {
      color: #666;
      font-size: 0.8em;
    }
    
    .flash {
      padding: 10px;
      margin: 10px 0;
      border-radius: 5px;
    }
    
    .flash.error {
      background-color: #ffdddd;
      border: 1px solid #ffcccc;
    }
    
    form div {
      margin-bottom: 15px;
    }
    
    label {
      display: block;
      margin-bottom: 5px;
    }
    
    input[type="text"],
    input[type="email"],
    input[type="password"],
    textarea {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    
    textarea {
      height: 200px;
    }
    
    .button {
      display: inline-block;
      background-color: #cc342d;
      color: white;
      padding: 10px 15px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      text-decoration: none;
    }
    
    .button.secondary {
      background-color: #666;
    }
  </style>
</head>
<body>
  <header>
    <div class="container">
      <h1><a href="/" style="color: white; text-decoration: none;">Ruby Blog</a></h1>
      <nav>
        <% if logged_in? %>
          <span>Hello, <%= h(current_user["username"]) %></span>
          <a href="/posts/new">New Post</a>
          <a href="/logout">Logout</a>
        <% else %>
          <a href="/login">Login</a>
          <a href="/signup">Sign Up</a>
        <% end %>
      </nav>
    </div>
  </header>
  
  <div class="container">
    <% if @error %>
      <div class="flash error">
        <%= h(@error) %>
      </div>
    <% end %>
    
    <%= yield %>
  </div>
</body>
</html>

@@ index
<h1>Recent Posts</h1>

<% if @posts.empty? %>
  <p>No posts yet. <% if logged_in? %><a href="/posts/new">Create the first one!</a><% end %></p>
<% else %>
  <% @posts.each do |post| %>
    <div class="post">
      <h2><a href="/posts/<%= post["id"] %>"><%= h(post["title"]) %></a></h2>
      <div class="post-meta">
        Posted by <%= h(post["username"]) %> on <%= format_date(post["created_at"]) %>
      </div>
      <p><%= h(post["content"])[0..200] %><%= "..." if post["content"].length > 200 %></p>
      <a href="/posts/<%= post["id"] %>">Read more</a>
    </div>
  <% end %>
<% end %>

@@ login
<h1>Login</h1>

<form action="/login" method="post">
  <div>
    <label for="username">Username:</label>
    <input type="text" id="username" name="username" required>
  </div>
  
  <div>
    <label for="password">Password:</label>
    <input type="password" id="password" name="password" required>
  </div>
  
  <div>
    <input type="submit" value="Login" class="button">
  </div>
</form>

<p>Don't have an account? <a href="/signup">Sign up</a></p>

@@ signup
<h1>Sign Up</h1>

<form action="/signup" method="post">
  <div>
    <label for="username">Username:</label>
    <input type="text" id="username" name="username" required>
  </div>
  
  <div>
    <label for="email">Email:</label>
    <input type="email" id="email" name="email" required>
  </div>
  
  <div>
    <label for="password">Password:</label>
    <input type="password" id="password" name="password" required>
  </div>
  
  <div>
    <label for="password_confirmation">Confirm Password:</label>
    <input type="password" id="password_confirmation" name="password_confirmation" required>
  </div>
  
  <div>
    <input type="submit" value="Sign Up" class="button">
  </div>
</form>

<p>Already have an account? <a href="/login">Login</a></p>

@@ new_post
<h1>Create New Post</h1>

<form action="/posts" method="post">
  <div>
    <label for="title">Title:</label>
    <input type="text" id="title" name="title" required>
  </div>
  
  <div>
    <label for="content">Content:</label>
    <textarea id="content" name="content" required></textarea>
  </div>
  
  <div>
    <input type="submit" value="Create Post" class="button">
    <a href="/" class="button secondary">Cancel</a>
  </div>
</form>

@@ show_post
<div class="post">
  <h1><%= h(@post["title"]) %></h1>
  
  <div class="post-meta">
    Posted by <%= h(@post["username"]) %> on <%= format_date(@post["created_at"]) %>
    <% if @post["updated_at"] != @post["created_at"] %>
      (Updated on <%= format_date(@post["updated_at"]) %>)
    <% end %>
  </div>
  
  <div class="post-content">
    <%= h(@post["content"]).split("\n").join("<br>") %>
  </div>
  
  <% if logged_in? && @post["user_id"] == current_user["id"] %>
    <div style="margin-top: 20px;">
      <a href="/posts/<%= @post["id"] %>/edit" class="button">Edit</a>
      
      <form action="/posts/<%= @post["id"] %>/delete" method="post" style="display: inline;">
        <button type="submit" class="button secondary" onclick="return confirm('Are you sure you want to delete this post?')">Delete</button>
      </form>
    </div>
  <% end %>
</div>

<h2>Comments (<%= @comments.length %>)</h2>

<% if logged_in? %>
  <form action="/posts/<%= @post["id"] %>/comments" method="post">
    <div>
      <label for="content">Add a comment:</label>
      <textarea id="content" name="content" required style="height: 100px;"></textarea>
    </div>
    
    <div>
      <input type="submit" value="Post Comment" class="button">
    </div>
  </form>
<% else %>
  <p><a href="/login">Login</a> to leave a comment.</p>
<% end %>

<% if @comments.empty? %>
  <p>No comments yet.</p>
<% else %>
  <% @comments.each do |comment| %>
    <div class="comment">
      <div class="comment-content">
        <%= h(comment["content"]).split("\n").join("<br>") %>
      </div>
      
      <div class="comment-meta">
        Posted by <%= h(comment["username"]) %> on <%= format_date(comment["created_at"]) %>
      </div>
    </div>
  <% end %>
<% end %>

@@ edit_post
<h1>Edit Post</h1>

<form action="/posts/<%= @post["id"] %>" method="post">
  <div>
    <label for="title">Title:</label>
    <input type="text" id="title" name="title" value="<%= h(@post["title"]) %>" required>
  </div>
  
  <div>
    <label for="content">Content:</label>
    <textarea id="content" name="content" required><%= h(@post["content"]) %></textarea>
  </div>
  
  <div>
    <input type="submit" value="Update Post" class="button">
    <a href="/posts/<%= @post["id"] %>" class="button secondary">Cancel</a>
  </div>
</form>
