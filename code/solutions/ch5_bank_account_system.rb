#!/usr/bin/env ruby
# Chapter 5: Mini Project - Bank Account System

class BankAccount
  attr_reader :account_number, :owner_name, :balance
  
  @@total_accounts = 0  # Class variable to track total accounts
  
  def initialize(owner_name, initial_deposit = 0)
    @account_number = generate_account_number
    @owner_name = owner_name
    @balance = initial_deposit
    @@total_accounts += 1
    
    puts "Account ##{@account_number} created successfully for #{@owner_name}."
  end
  
  def deposit(amount)
    if amount <= 0
      puts "Error: Deposit amount must be positive."
      return false
    end
    
    @balance += amount
    puts "Deposited $#{amount}. New balance: $#{@balance}"
    true
  end
  
  def withdraw(amount)
    if amount <= 0
      puts "Error: Withdrawal amount must be positive."
      return false
    end
    
    if amount > @balance
      puts "Error: Insufficient funds. Current balance: $#{@balance}"
      return false
    end
    
    @balance -= amount
    puts "Withdrew $#{amount}. New balance: $#{@balance}"
    true
  end
  
  def display_info
    puts "\nAccount Information:"
    puts "===================="
    puts "Account Number: #{@account_number}"
    puts "Owner: #{@owner_name}"
    puts "Current Balance: $#{@balance}"
    puts "===================="
  end
  
  def self.total_accounts
    @@total_accounts
  end
  
  private
  
  def generate_account_number
    # Simple account number generation - would use more sophisticated method in real system
    rand(10000..99999)
  end
end

# Demonstration code
if __FILE__ == $PROGRAM_NAME
  # Create accounts
  alice_account = BankAccount.new("Alice Smith", 1000)
  bob_account = BankAccount.new("Bob Johnson", 500)
  
  # Display initial account information
  alice_account.display_info
  bob_account.display_info
  
  # Perform operations
  alice_account.deposit(300)
  bob_account.withdraw(200)
  
  # Try invalid operations
  alice_account.withdraw(2000)  # Exceeds balance
  bob_account.deposit(-50)      # Negative deposit
  
  # Display final account information
  alice_account.display_info
  bob_account.display_info
  
  # Display total accounts created
  puts "\nTotal accounts created: #{BankAccount.total_accounts}"
end
