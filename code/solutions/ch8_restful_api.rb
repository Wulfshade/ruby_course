#!/usr/bin/env ruby
# Chapter 8: Mini Project - RESTful API Design

require 'sinatra'
require 'json'
require 'securerandom'

# Configuration
set :port, 4567
set :bind, '0.0.0.0'

# In-memory data store
TASKS = {}

# Middleware for JSON parsing
before do
  content_type :json
  
  # Parse JSON body for POST and PUT requests
  if request.post? || request.put?
    begin
      request.body.rewind
      @request_payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 400, { error: "Invalid JSON" }.to_json
    end
  end
end

# Helper methods
def json_response(status_code, data)
  status status_code
  data.to_json
end

# Routes

# GET /tasks - List all tasks
get '/tasks' do
  # Optional filtering by status
  if params[:status]
    filtered_tasks = TASKS.select { |_, task| task["status"] == params[:status] }
    json_response 200, filtered_tasks
  else
    json_response 200, TASKS
  end
end

# GET /tasks/:id - Get a specific task
get '/tasks/:id' do
  task_id = params[:id]
  
  if TASKS[task_id]
    json_response 200, TASKS[task_id]
  else
    json_response 404, { error: "Task not found" }
  end
end

# POST /tasks - Create a new task
post '/tasks' do
  # Validate required fields
  unless @request_payload && @request_payload["title"]
    json_response 400, { error: "Title is required" }
  end
  
  task_id = SecureRandom.uuid
  
  task = {
    "id" => task_id,
    "title" => @request_payload["title"],
    "description" => @request_payload["description"] || "",
    "status" => @request_payload["status"] || "pending",
    "created_at" => Time.now.iso8601
  }
  
  TASKS[task_id] = task
  json_response 201, task
end

# PUT /tasks/:id - Update a task
put '/tasks/:id' do
  task_id = params[:id]
  
  unless TASKS[task_id]
    json_response 404, { error: "Task not found" }
  end
  
  # Update task properties
  task = TASKS[task_id]
  task["title"] = @request_payload["title"] if @request_payload["title"]
  task["description"] = @request_payload["description"] if @request_payload.key?("description")
  task["status"] = @request_payload["status"] if @request_payload["status"]
  task["updated_at"] = Time.now.iso8601
  
  json_response 200, task
end

# DELETE /tasks/:id - Delete a task
delete '/tasks/:id' do
  task_id = params[:id]
  
  if TASKS[task_id]
    TASKS.delete(task_id)
    json_response 204, {}
  else
    json_response 404, { error: "Task not found" }
  end
end

# Error handling
not_found do
  json_response 404, { error: "Endpoint not found" }
end

error do
  json_response 500, { error: "Internal server error" }
end

# Documentation endpoint
get '/' do
  content_type :html
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Task API Documentation</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1, h2 { color: #333; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
        .endpoint { margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 20px; }
        .method { font-weight: bold; }
        .get { color: #2196F3; }
        .post { color: #4CAF50; }
        .put { color: #FF9800; }
        .delete { color: #F44336; }
      </style>
    </head>
    <body>
      <h1>Task API Documentation</h1>
      
      <div class="endpoint">
        <h2><span class="method get">GET</span> /tasks</h2>
        <p>Retrieve all tasks. Can filter by status with ?status=pending|completed|in_progress</p>
        <pre>curl -X GET http://localhost:4567/tasks</pre>
      </div>
      
      <div class="endpoint">
        <h2><span class="method get">GET</span> /tasks/:id</h2>
        <p>Retrieve a specific task by ID</p>
        <pre>curl -X GET http://localhost:4567/tasks/task_id</pre>
      </div>
      
      <div class="endpoint">
        <h2><span class="method post">POST</span> /tasks</h2>
        <p>Create a new task</p>
        <pre>curl -X POST http://localhost:4567/tasks -H "Content-Type: application/json" -d '{"title":"Learn Ruby","description":"Study API development","status":"pending"}'</pre>
      </div>
      
      <div class="endpoint">
        <h2><span class="method put">PUT</span> /tasks/:id</h2>
        <p>Update an existing task</p>
        <pre>curl -X PUT http://localhost:4567/tasks/task_id -H "Content-Type: application/json" -d '{"status":"completed"}'</pre>
      </div>
      
      <div class="endpoint">
        <h2><span class="method delete">DELETE</span> /tasks/:id</h2>
        <p>Delete a task</p>
        <pre>curl -X DELETE http://localhost:4567/tasks/task_id</pre>
      </div>
    </body>
    </html>
  HTML
end
