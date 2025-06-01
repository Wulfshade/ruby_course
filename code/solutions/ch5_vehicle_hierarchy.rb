#!/usr/bin/env ruby
# Chapter 5: Mini Project - Vehicle Hierarchy

# Base Vehicle class
class Vehicle
  attr_reader :make, :model, :year
  
  def initialize(make, model, year)
    @make = make
    @model = model
    @year = year
  end
  
  def start_engine
    puts "#{self.class} engine started."
  end
  
  def stop_engine
    puts "#{self.class} engine stopped."
  end
  
  def info
    "#{year} #{make} #{model}"
  end
  
  def to_s
    "#{self.class}: #{info}"
  end
end

# Car inherits from Vehicle
class Car < Vehicle
  attr_reader :doors, :type
  
  def initialize(make, model, year, doors, type = "sedan")
    super(make, model, year)
    @doors = doors
    @type = type
  end
  
  def honk
    puts "Beep beep!"
  end
  
  def info
    "#{super} (#{type}, #{doors} doors)"
  end
end

# Truck inherits from Vehicle
class Truck < Vehicle
  attr_reader :bed_size, :towing_capacity
  
  def initialize(make, model, year, bed_size, towing_capacity)
    super(make, model, year)
    @bed_size = bed_size
    @towing_capacity = towing_capacity
  end
  
  def load(cargo)
    puts "Loading #{cargo} into truck bed."
  end
  
  def unload
    puts "Unloading cargo from truck bed."
  end
  
  def info
    "#{super} (#{bed_size} bed, #{towing_capacity}lb towing)"
  end
end

# Motorcycle inherits from Vehicle
class Motorcycle < Vehicle
  attr_reader :type, :cc
  
  def initialize(make, model, year, type, cc)
    super(make, model, year)
    @type = type
    @cc = cc
  end
  
  def wheelie
    puts "Performing a wheelie! (Please don't try this at home)"
  end
  
  def info
    "#{super} (#{type}, #{cc}cc)"
  end
end

# ElectricVehicle mixin module
module ElectricVehicle
  attr_reader :battery_capacity, :range
  
  def initialize_electric(battery_capacity, range)
    @battery_capacity = battery_capacity # in kWh
    @range = range # in miles
  end
  
  def charge
    puts "Charging battery..."
  end
  
  def battery_status
    "Battery capacity: #{battery_capacity}kWh, Range: #{range} miles"
  end
end

# ElectricCar - multiple inheritance through class and module
class ElectricCar < Car
  include ElectricVehicle
  
  def initialize(make, model, year, doors, battery_capacity, range)
    super(make, model, year, doors, "electric")
    initialize_electric(battery_capacity, range)
  end
  
  def start_engine
    puts "#{self.class} motor activated silently."
  end
  
  def info
    "#{super}, #{battery_status}"
  end
end

# Fleet class to manage a collection of vehicles
class Fleet
  def initialize(name)
    @name = name
    @vehicles = []
  end
  
  def add_vehicle(vehicle)
    @vehicles << vehicle
    puts "Added #{vehicle.info} to the #{@name} fleet."
  end
  
  def remove_vehicle(vehicle)
    if @vehicles.delete(vehicle)
      puts "Removed #{vehicle.info} from the #{@name} fleet."
    else
      puts "Vehicle not found in fleet."
    end
  end
  
  def list_vehicles
    puts "\n#{@name} Fleet Inventory:"
    puts "------------------------"
    
    if @vehicles.empty?
      puts "No vehicles in fleet."
    else
      @vehicles.each_with_index do |vehicle, index|
        puts "#{index + 1}. #{vehicle}"
      end
      puts "\nTotal vehicles: #{@vehicles.size}"
    end
  end
  
  def count_by_type
    counts = Hash.new(0)
    @vehicles.each do |vehicle|
      counts[vehicle.class] += 1
    end
    
    puts "\nVehicle Types in #{@name} Fleet:"
    counts.each do |type, count|
      puts "#{type}: #{count}"
    end
  end
end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  # Create various vehicles
  sedan = Car.new("Honda", "Accord", 2022, 4)
  truck = Truck.new("Ford", "F-150", 2021, "6.5ft", 13200)
  motorcycle = Motorcycle.new("Harley-Davidson", "Street Glide", 2023, "Cruiser", 1868)
  electric_car = ElectricCar.new("Tesla", "Model 3", 2022, 4, 82, 315)
  
  # Test vehicle methods
  puts "\n=== Vehicle Tests ==="
  
  puts "\nTesting Car..."
  puts sedan.info
  sedan.start_engine
  sedan.honk
  sedan.stop_engine
  
  puts "\nTesting Truck..."
  puts truck.info
  truck.start_engine
  truck.load("construction materials")
  truck.unload
  truck.stop_engine
  
  puts "\nTesting Motorcycle..."
  puts motorcycle.info
  motorcycle.start_engine
  motorcycle.wheelie
  motorcycle.stop_engine
  
  puts "\nTesting Electric Car..."
  puts electric_car.info
  electric_car.start_engine
  electric_car.charge
  electric_car.stop_engine
  
  # Create and manage a fleet
  puts "\n=== Fleet Management ==="
  fleet = Fleet.new("Ruby Motors")
  
  fleet.add_vehicle(sedan)
  fleet.add_vehicle(truck)
  fleet.add_vehicle(motorcycle)
  fleet.add_vehicle(electric_car)
  
  fleet.list_vehicles
  fleet.count_by_type
  
  # Remove a vehicle
  puts "\nRemoving a vehicle..."
  fleet.remove_vehicle(motorcycle)
  
  fleet.list_vehicles
end
