#!/usr/bin/env ruby
# Chapter 7: Mini Project - Book Library RSpec Tests

require_relative 'ch7_book_library'
require 'rspec'

RSpec.describe Book do
  let(:book) { Book.new("Ruby Programming", "Matz", "978-1-93435-608-1") }
  
  describe "#initialize" do
    it "sets the title, author, and ISBN" do
      expect(book.title).to eq("Ruby Programming")
      expect(book.author).to eq("Matz")
      expect(book.isbn).to eq("978-1-93435-608-1")
    end
    
    it "sets availability to true by default" do
      expect(book.available).to be true
    end
  end
  
  describe "#checkout" do
    it "makes the book unavailable if it was available" do
      expect(book.checkout).to be true
      expect(book.available).to be false
    end
    
    it "returns false if the book is already checked out" do
      book.checkout
      expect(book.checkout).to be false
    end
  end
  
  describe "#return" do
    it "makes the book available if it was checked out" do
      book.checkout
      expect(book.return).to be true
      expect(book.available).to be true
    end
    
    it "returns false if the book is already available" do
      expect(book.return).to be false
    end
  end
  
  describe "#available?" do
    it "returns true if the book is available" do
      expect(book.available?).to be true
    end
    
    it "returns false if the book is checked out" do
      book.checkout
      expect(book.available?).to be false
    end
  end
  
  describe "#to_s" do
    it "includes title, author, ISBN, and availability status" do
      expect(book.to_s).to include("Ruby Programming")
      expect(book.to_s).to include("Matz")
      expect(book.to_s).to include("978-1-93435-608-1")
      expect(book.to_s).to include("Available")
      
      book.checkout
      expect(book.to_s).to include("Checked out")
    end
  end
end

RSpec.describe Library do
  let(:library) { Library.new }
  let(:book1) { Book.new("Ruby Programming", "Matz", "978-1-93435-608-1") }
  let(:book2) { Book.new("Practical Object-Oriented Design", "Sandi Metz", "978-0-13-456936-9") }
  let(:book3) { Book.new("Eloquent Ruby", "Russ Olsen", "978-0-321-58410-6") }
  
  before do
    library.add_book(book1)
    library.add_book(book2)
    library.add_book(book3)
  end
  
  describe "#initialize" do
    it "creates an empty book collection" do
      expect(Library.new.books).to be_empty
    end
  end
  
  describe "#add_book" do
    it "adds a book to the collection" do
      new_library = Library.new
      expect { new_library.add_book(book1) }.to change { new_library.books.count }.by(1)
    end
  end
  
  describe "#find_book_by_title" do
    it "finds a book by its title (case insensitive)" do
      expect(library.find_book_by_title("ruby")).to eq(book1)
      expect(library.find_book_by_title("OBJECT")).to eq(book2)
    end
    
    it "returns nil if no book matches" do
      expect(library.find_book_by_title("Python")).to be_nil
    end
  end
  
  describe "#find_book_by_author" do
    it "finds a book by its author (case insensitive)" do
      expect(library.find_book_by_author("matz")).to eq(book1)
      expect(library.find_book_by_author("OLSEN")).to eq(book3)
    end
    
    it "returns nil if no book matches" do
      expect(library.find_book_by_author("Kent Beck")).to be_nil
    end
  end
  
  describe "#find_book_by_isbn" do
    it "finds a book by its ISBN" do
      expect(library.find_book_by_isbn("978-0-321-58410-6")).to eq(book3)
    end
    
    it "returns nil if no book matches" do
      expect(library.find_book_by_isbn("invalid-isbn")).to be_nil
    end
  end
  
  describe "#available_books" do
    it "returns all available books" do
      expect(library.available_books.count).to eq(3)
      
      book1.checkout
      expect(library.available_books.count).to eq(2)
      expect(library.available_books).not_to include(book1)
    end
  end
  
  describe "#checked_out_books" do
    it "returns all checked out books" do
      expect(library.checked_out_books).to be_empty
      
      book2.checkout
      expect(library.checked_out_books.count).to eq(1)
      expect(library.checked_out_books).to include(book2)
    end
  end
  
  describe "#checkout_book" do
    it "checks out a book" do
      expect(library.checkout_book(book3)).to be true
      expect(book3.available?).to be false
    end
  end
  
  describe "#return_book" do
    it "returns a checked out book" do
      book1.checkout
      expect(library.return_book(book1)).to be true
      expect(book1.available?).to be true
    end
  end
end
