#!/usr/bin/env ruby
# Chapter 11: Mini Project - ActiveRecord CRUD Application

require 'active_record'
require 'sqlite3'
require 'logger'

# Configure database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'  # In-memory database for demonstration
)

# Set up logging
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::INFO

# Define the schema
ActiveRecord::Schema.define do
  create_table :books do |t|
    t.string :title, null: false
    t.string :author, null: false
    t.integer :year
    t.string :genre
    t.boolean :available, default: true
    t.timestamps
  end
  
  create_table :users do |t|
    t.string :name, null: false
    t.string :email, null: false
    t.timestamps
  end
  
  create_table :checkouts do |t|
    t.references :user
    t.references :book
    t.datetime :due_date
    t.datetime :returned_at
    t.timestamps
  end
end

# Define models
class Book < ActiveRecord::Base
  has_many :checkouts
  has_many :users, through: :checkouts
  
  validates :title, :author, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  
  scope :available, -> { where(available: true) }
  scope :by_author, ->(author) { where("author LIKE ?", "%#{author}%") }
  scope :by_genre, ->(genre) { where(genre: genre) }
  
  def checkout_to(user, days = 14)
    return false unless available?
    
    transaction do
      update!(available: false)
      Checkout.create!(
        user: user,
        book: self,
        due_date: days.days.from_now
      )
    end
    true
  end
  
  def return_book
    transaction do
      update!(available: true)
      checkouts.where(returned_at: nil).update_all(returned_at: Time.now)
    end
    true
  end
end

class User < ActiveRecord::Base
  has_many :checkouts
  has_many :books, through: :checkouts
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def current_checkouts
    checkouts.where(returned_at: nil).includes(:book)
  end
  
  def checkout_history
    checkouts.includes(:book).order(created_at: :desc)
  end
  
  def overdue_books
    current_checkouts.where("due_date < ?", Time.now).includes(:book)
  end
end

class Checkout < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
  
  validates :user, :book, :due_date, presence: true
  
  scope :overdue, -> { where("due_date < ? AND returned_at IS NULL", Time.now) }
  scope :current, -> { where(returned_at: nil) }
  
  def overdue?
    returned_at.nil? && due_date < Time.now
  end
  
  def days_overdue
    return 0 unless overdue?
    ((Time.now - due_date) / 86400).to_i
  end
end

# Demo application
if __FILE__ == $PROGRAM_NAME
  puts "Library Management System Demo"
  puts "============================="
  
  # Create users
  alice = User.create!(name: "Alice Smith", email: "alice@example.com")
  bob = User.create!(name: "Bob Johnson", email: "bob@example.com")
  
  # Create books
  books = [
    Book.create!(title: "Ruby Programming", author: "Matz", year: 2008, genre: "Programming"),
    Book.create!(title: "Design Patterns in Ruby", author: "Russ Olsen", year: 2007, genre: "Programming"),
    Book.create!(title: "The Pragmatic Programmer", author: "Dave Thomas & Andy Hunt", year: 1999, genre: "Programming"),
    Book.create!(title: "Eloquent Ruby", author: "Russ Olsen", year: 2011, genre: "Programming")
  ]
  
  puts "\nAvailable books:"
  Book.available.each { |book| puts "- #{book.title} by #{book.author} (#{book.year})" }
  
  # Checkout books
  puts "\nChecking out books..."
  books[0].checkout_to(alice)
  books[1].checkout_to(alice)
  books[2].checkout_to(bob)
  
  puts "\nAlice's checkouts:"
  alice.current_checkouts.each do |checkout|
    puts "- #{checkout.book.title}, due: #{checkout.due_date.strftime('%Y-%m-%d')}"
  end
  
  puts "\nBob's checkouts:"
  bob.current_checkouts.each do |checkout|
    puts "- #{checkout.book.title}, due: #{checkout.due_date.strftime('%Y-%m-%d')}"
  end
  
  # Return a book
  puts "\nReturning a book..."
  books[0].return_book
  
  puts "\nUpdated available books:"
  Book.available.each { |book| puts "- #{book.title} by #{book.author}" }
  
  # Search by author
  puts "\nBooks by Russ Olsen:"
  Book.by_author("Olsen").each { |book| puts "- #{book.title} (#{book.year})" }
  
  # Update a book
  puts "\nUpdating a book..."
  books[3].update(year: 2012)
  puts "Updated: #{books[3].title} - #{books[3].year}"
  
  # Delete a book
  puts "\nDeleting a book..."
  books[3].destroy
  puts "Total books after deletion: #{Book.count}"
  
  puts "\nDemo completed."
end
