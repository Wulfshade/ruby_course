#!/usr/bin/env ruby
# Chapter 10: Mini Project - Enhanced Attribute Framework

module EnhancedAttributes
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end
  
  module ClassMethods
    def attribute(name, options = {})
      # Track attributes in the class
      @attributes ||= {}
      @attributes[name] = options
      
      # Define reader method
      define_method(name) do
        get_attribute(name)
      end
      
      # Define writer method
      define_method("#{name}=") do |value|
        set_attribute(name, value)
      end
      
      # Define predicate method for boolean attributes
      if options[:type] == :boolean
        define_method("#{name}?") do
          !!get_attribute(name)
        end
      end
    end
    
    def attributes
      @attributes ||= {}
    end
    
    # Inherit attributes from parent classes
    def inherited(subclass)
      subclass.instance_variable_set(:@attributes, attributes.dup)
    end
  end
  
  module InstanceMethods
    def initialize(attributes = {})
      @attribute_values = {}
      @attribute_changes = {}
      
      # Set default values
      self.class.attributes.each do |name, options|
        if options.key?(:default)
          default = options[:default]
          default = default.call if default.is_a?(Proc)
          @attribute_values[name] = default
        end
      end
      
      # Set initial attributes
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end
    
    def get_attribute(name)
      @attribute_values[name]
    end
    
    def set_attribute(name, value)
      options = self.class.attributes[name] || {}
      
      # Type checking
      if options[:type] && !value.nil?
        type = options[:type]
        case type
        when :string, String
          raise TypeError, "#{name} must be a String" unless value.is_a?(String)
        when :integer, Integer
          raise TypeError, "#{name} must be an Integer" unless value.is_a?(Integer)
        when :float, Float
          raise TypeError, "#{name} must be a Float" unless value.is_a?(Float)
        when :boolean
          unless [true, false].include?(value)
            raise TypeError, "#{name} must be true or false"
          end
        when Class
          raise TypeError, "#{name} must be a #{type}" unless value.is_a?(type)
        end
      end
      
      # Validation
      if options[:validate]
        validator = options[:validate]
        
        case validator
        when Proc
          valid = validator.call(value)
        when Symbol
          valid = send(validator, value)
        else
          valid = true
        end
        
        unless valid
          raise ArgumentError, "Invalid value for #{name}: #{value}"
        end
      end
      
      # Track changes
      old_value = @attribute_values[name]
      unless old_value == value
        @attribute_changes[name] = [old_value, value]
      end
      
      # Set the value
      @attribute_values[name] = value
    end
    
    def changes
      @attribute_changes.dup
    end
    
    def changed_attributes
      @attribute_changes.keys
    end
    
    def changed?
      !@attribute_changes.empty?
    end
    
    def reset_changes
      @attribute_changes.clear
    end
  end
end

# Example usage
class Person
  include EnhancedAttributes
  
  attribute :name, type: String, validate: ->(value) { value.length > 0 }
  attribute :age, type: Integer, validate: ->(value) { value >= 0 }
  attribute :email, type: String, validate: :valid_email?
  attribute :active, type: :boolean, default: true
  
  def valid_email?(email)
    email.to_s.include?('@') && email.to_s.include?('.')
  end
  
  def to_s
    "#{name}, #{age} - #{email} (#{active? ? 'active' : 'inactive'})"
  end
end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  puts "Enhanced Attribute Framework Demo"
  puts "=================================="
  
  person = Person.new(name: "Ruby Developer", age: 30, email: "dev@ruby-lang.org")
  puts "Created person: #{person}"
  
  begin
    puts "\nTrying to set invalid age..."
    person.age = -5
  rescue ArgumentError => e
    puts "Error: #{e.message}"
  end
  
  begin
    puts "\nTrying to set invalid email..."
    person.email = "not-an-email"
  rescue ArgumentError => e
    puts "Error: #{e.message}"
  end
  
  puts "\nChanging attributes..."
  person.name = "Advanced Ruby Developer"
  person.age = 31
  
  puts "Changed attributes: #{person.changed_attributes.join(', ')}"
  puts "Changes: #{person.changes}"
  puts "Updated person: #{person}"
  
  puts "\nResetting changes..."
  person.reset_changes
  puts "Changed? #{person.changed?}"
  
  # Test inheritance
  class Employee < Person
    attribute :department, type: String
    attribute :salary, type: Float, validate: ->(value) { value > 0 }
  end
  
  puts "\nCreating employee (inherited from Person)..."
  employee = Employee.new(
    name: "Ruby Team Lead",
    age: 35,
    email: "lead@ruby-lang.org",
    department: "Engineering",
    salary: 100000.00
  )
  
  puts "Employee: #{employee}"
  puts "Department: #{employee.department}"
  puts "Salary: $#{employee.salary}"
end
