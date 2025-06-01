#!/usr/bin/env ruby
# Chapter 3: Mini Project - Address Book

class AddressBook
  def initialize
    @contacts = {}
  end
  
  def add_contact(name, details = {})
    if @contacts.key?(name)
      puts "Contact '#{name}' already exists. Use update_contact to modify."
      return false
    end
    
    @contacts[name] = details
    puts "Added contact: #{name}"
    true
  end
  
  def update_contact(name, details = {})
    unless @contacts.key?(name)
      puts "Contact '#{name}' not found."
      return false
    end
    
    # Merge new details with existing ones
    @contacts[name].merge!(details)
    puts "Updated contact: #{name}"
    true
  end
  
  def delete_contact(name)
    if @contacts.delete(name)
      puts "Deleted contact: #{name}"
      true
    else
      puts "Contact '#{name}' not found."
      false
    end
  end
  
  def find_contact(name)
    if @contacts.key?(name)
      display_contact(name)
      @contacts[name]
    else
      puts "Contact '#{name}' not found."
      nil
    end
  end
  
  def display_contact(name)
    unless @contacts.key?(name)
      puts "Contact '#{name}' not found."
      return
    end
    
    contact = @contacts[name]
    puts "\nContact: #{name}"
    puts "------------------------"
    contact.each do |key, value|
      puts "#{key.capitalize}: #{value}"
    end
    puts "------------------------"
  end
  
  def list_all_contacts
    if @contacts.empty?
      puts "Address book is empty."
      return
    end
    
    puts "\n===== CONTACTS =====\n"
    @contacts.keys.sort.each do |name|
      puts "- #{name}"
    end
    puts "\nTotal contacts: #{@contacts.size}"
  end
  
  def search_contacts(term)
    term = term.to_s.downcase
    results = @contacts.select do |name, details|
      name_match = name.downcase.include?(term)
      details_match = details.any? do |_, value|
        value.to_s.downcase.include?(term)
      end
      
      name_match || details_match
    end
    
    if results.empty?
      puts "No contacts found matching '#{term}'."
      return []
    end
    
    puts "\n===== SEARCH RESULTS =====\n"
    results.each do |name, _|
      puts "- #{name}"
    end
    puts "\nFound #{results.size} matching contacts."
    
    results
  end
end

# Command-line interface
if __FILE__ == $PROGRAM_NAME
  address_book = AddressBook.new
  
  # Add some sample contacts
  address_book.add_contact("John Doe", {
    email: "john@example.com",
    phone: "555-1234",
    address: "123 Main St",
    notes: "Work contact"
  })
  
  address_book.add_contact("Jane Smith", {
    email: "jane@example.com",
    phone: "555-5678",
    address: "456 Oak Ave",
    notes: "Friend from college"
  })
  
  address_book.add_contact("Ruby Developer", {
    email: "dev@ruby-lang.org",
    phone: "555-RUBY",
    address: "Ruby HQ",
    github: "rubydev",
    notes: "Open source contributor"
  })
  
  puts "\n===== ADDRESS BOOK DEMO =====\n"
  
  loop do
    puts "\nAvailable commands:"
    puts "1. add       - Add a new contact"
    puts "2. update    - Update an existing contact"
    puts "3. delete    - Delete a contact"
    puts "4. find      - Find a contact by name"
    puts "5. list      - List all contacts"
    puts "6. search    - Search contacts"
    puts "7. exit      - Exit the program"
    
    print "\nEnter command: "
    command = gets.chomp.downcase
    
    case command
    when "1", "add"
      print "Enter name: "
      name = gets.chomp
      
      details = {}
      print "Enter email: "
      details[:email] = gets.chomp
      
      print "Enter phone: "
      details[:phone] = gets.chomp
      
      print "Enter address: "
      details[:address] = gets.chomp
      
      print "Enter notes: "
      details[:notes] = gets.chomp
      
      address_book.add_contact(name, details)
    
    when "2", "update"
      print "Enter name of contact to update: "
      name = gets.chomp
      
      if address_book.find_contact(name)
        details = {}
        print "Enter new email (leave blank to keep current): "
        email = gets.chomp
        details[:email] = email unless email.empty?
        
        print "Enter new phone (leave blank to keep current): "
        phone = gets.chomp
        details[:phone] = phone unless phone.empty?
        
        print "Enter new address (leave blank to keep current): "
        address = gets.chomp
        details[:address] = address unless address.empty?
        
        print "Enter new notes (leave blank to keep current): "
        notes = gets.chomp
        details[:notes] = notes unless notes.empty?
        
        address_book.update_contact(name, details)
      end
    
    when "3", "delete"
      print "Enter name of contact to delete: "
      name = gets.chomp
      address_book.delete_contact(name)
    
    when "4", "find"
      print "Enter name to find: "
      name = gets.chomp
      address_book.find_contact(name)
    
    when "5", "list"
      address_book.list_all_contacts
    
    when "6", "search"
      print "Enter search term: "
      term = gets.chomp
      address_book.search_contacts(term)
    
    when "7", "exit"
      puts "Goodbye!"
      break
    
    else
      puts "Unknown command. Try again."
    end
  end
end
