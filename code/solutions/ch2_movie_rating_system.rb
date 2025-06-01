# Chapter 2: Mini Project - Movie Rating System

# Ask the user for their age
puts "Welcome to the Movie Rating System!"
print "Please enter your age: "
user_age = gets.chomp.to_i

# Based on the age, display which movie ratings they are allowed to watch
puts "\nBased on your age (#{user_age}), you can watch:"

if user_age >= 0 && user_age <= 12
  puts "- G rated movies"
  puts "- PG rated movies"
elsif user_age >= 13 && user_age <= 16
  puts "- G rated movies"
  puts "- PG rated movies"
  puts "- PG-13 rated movies"
elsif user_age >= 17
  puts "- All movie ratings (G, PG, PG-13, R, NC-17)"
else
  puts "Invalid age entered."
  exit
end

# Ask the user to enter a movie rating
print "\nEnter a movie rating to check if you can watch it: "
movie_rating = gets.chomp.upcase

# Tell them whether they can watch it or not
if movie_rating == "G" || movie_rating == "PG"
  puts "You can watch #{movie_rating} rated movies!"
elsif movie_rating == "PG-13"
  if user_age >= 13
    puts "You can watch PG-13 rated movies!"
  else
    puts "Sorry, you need to be at least 13 years old to watch PG-13 rated movies."
  end
elsif movie_rating == "R" || movie_rating == "NC-17"
  if user_age >= 17
    puts "You can watch #{movie_rating} rated movies!"
  else
    puts "Sorry, you need to be at least 17 years old to watch #{movie_rating} rated movies."
  end
else
  puts "Invalid movie rating! Valid ratings are: G, PG, PG-13, R, NC-17"
end
