# Chapter 3: Mini Project - Todo List

# Function to add a new todo item with priority
def add_todo(todos, title, priority)  
  # Create todo item as an array [id, title, priority, completed]
  id = todos.length + 1
  todo = [id, title, priority, 0]  # 0 means not completed
  
  todos.push(todo)
  return todos
end

# Function to mark a todo item as complete
def mark_complete(todos, id)
  todos.each do |todo|
    if todo[0] == id  # Check ID (first element)
      todo[3] = 1     # Set completed flag to 1 (true)
      break
    end
  end
  
  return todos
end

# Function to remove a todo item
def remove_todo(todos, id)
  new_todos = []

  for todo in todos
    if todo[0] != id
      new_todos.push(todo)
    end
  end

  return new_todos
end

# Function to list all todo items (sorted by priority)
def list_todos(todos)
  # Sort todos by priority (high, medium, low)
  priority_values = { "high" => 0, "medium" => 1, "low" => 2 }
  
  sorted_todos = todos.sort_by do |todo|
    priority_values[todo[2]]
  end
  
  if sorted_todos.empty?
    puts "No todos found"
  else
    sorted_todos.each do |todo|
      p todo
    end
  end
end

# Initialize with some sample todos
todos = []
todos = add_todo(todos, "Buy groceries", "high")
todos = add_todo(todos, "Do laundry", "medium")
todos = add_todo(todos, "Read Ruby book", "low")

# Mark first todo as complete
todos = mark_complete(todos, 1)

# Remove the second todo
todos = remove_todo(todos, 2)

# Display all todos sorted by priority
list_todos(todos)


# line 43

# todos = [
#   [1, "Take out trash", "low"],
#   [2, "Pay bills", "high"],
#   [3, "Walk dog", "medium"]
# ]

# priority_values = {
#   "high" => 0,
#   "medium" => 1,
#   "low" => 2
# }

# Phase 1: Mapping — convert each todo into a sort key

# Iteration 1:
#   todo = [1, "Take out trash", "low"]
#   todo[2] = "low"
#   priority_values["low"] = 2  → sort key is 2

# Iteration 2:
#   todo = [2, "Pay bills", "high"]
#   todo[2] = "high"
#   priority_values["high"] = 0  → sort key is 0

# Iteration 3:
#   todo = [3, "Walk dog", "medium"]
#   todo[2] = "medium"
#   priority_values["medium"] = 1  → sort key is 1

# Ruby internally creates pairs like:
# [
#   [[1, "Take out trash", "low"], 2],
#   [[2, "Pay bills", "high"], 0],
#   [[3, "Walk dog", "medium"], 1]
# ]

# Phase 2: Sorting — Ruby sorts based on the numeric sort keys

# Result of sorting:
# [
#   [2, "Pay bills", "high"],   # key = 0
#   [3, "Walk dog", "medium"],  # key = 1
#   [1, "Take out trash", "low"]# key = 2
# ]

# Finally, Ruby returns a new array of sorted todos