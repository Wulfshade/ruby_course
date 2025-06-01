#!/usr/bin/env ruby
# Chapter 7: Mini Project - Book Library Implementation

class Book
  attr_reader :title, :author, :isbn, :available
  
  def initialize(title, author, isbn)
    @title = title
    @author = author
    @isbn = isbn
    @available = true
  end
  
  def checkout
    if @available
      @available = false
      true
    else
      false
    end
  end
  
  def return
    if !@available
      @available = true
      true
    else
      false
    end
  end
  
  def available?
    @available
  end
  
  def to_s
    "#{@title} by #{@author} (ISBN: #{@isbn}) - #{available? ? 'Available' : 'Checked out'}"
  end
end

class Library
  attr_reader :books
  
  def initialize
    @books = []
  end
  
  def add_book(book)
    @books << book
  end
  
  def find_book_by_title(title)
    @books.find { |book| book.title.downcase.include?(title.downcase) }
  end
  
  def find_book_by_author(author)
    @books.find { |book| book.author.downcase.include?(author.downcase) }
  end
  
  def find_book_by_isbn(isbn)
    @books.find { |book| book.isbn == isbn }
  end
  
  def available_books
    @books.select(&:available?)
  end
  
  def checked_out_books
    @books.reject(&:available?)
  end
  
  def checkout_book(book)
    book.checkout
  end
  
  def return_book(book)
    book.return
  end
  
  def list_books
    if @books.empty?
      puts "No books in the library."
    else
      puts "Library Inventory:"
      @books.each { |book| puts "- #{book}" }
      puts "Total books: #{@books.count}"
      puts "Available books: #{available_books.count}"
      puts "Checked out books: #{checked_out_books.count}"
    end
  end
end
