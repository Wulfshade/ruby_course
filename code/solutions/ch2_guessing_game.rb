# Chapter 2: Mini Project - Guessing Game

# Set up the game
puts "Welcome to the Ruby Number Guessing Game!"
puts "I'm thinking of a number between 1 and 100."
puts "You have 10 attempts to guess it."

# Generate a secret random number between 1 and 100
secret_number = rand(1..100)

# Initialize variables to track game state
attempts_remaining = 10
guessed_correctly = false

# Main game loop - continue while attempts remain
while attempts_remaining > 0
  # Tell the user how many attempts they have left
  print "\nYou have #{attempts_remaining} attempts left. Enter your guess: "
  
  # Get the user's guess
  guess = gets.chomp.to_i
  
  # Reduce the number of attempts
  attempts_remaining -= 1
  
  # Compare the guess with the secret number
  if guess < secret_number
    puts "Too low! Try a higher number."
  elsif guess > secret_number
    puts "Too high! Try a lower number."
  else
    # User guessed correctly
    guessed_correctly = true
    break
  end
  
  # Give a hint after 5 attempts
  if attempts_remaining == 5
    puts "HINT: The number is between #{[secret_number - 10, 1].max} and #{[secret_number + 10, 100].min}."
  end
end

# End of game - display appropriate message
if guessed_correctly
  attempts_used = 10 - attempts_remaining
  puts "\nCongratulations! You guessed the number #{secret_number} correctly!"
  puts "It took you #{attempts_used} attempt#{attempts_used == 1 ? '' : 's'}."
  
  # Provide feedback based on their performance
  if attempts_used <= 3
    puts "Amazing! You're a mind reader!"
  elsif attempts_used <= 5
    puts "Great job! You're a skilled guesser!"
  elsif attempts_used <= 7
    puts "Good work! Your guessing skills are solid."
  else
    puts "You got it! With some practice, you'll guess even faster next time."
  end
else
  puts "\nGame over! You've used all your attempts."
  puts "The number I was thinking of was #{secret_number}."
  puts "Better luck next time!"
end
