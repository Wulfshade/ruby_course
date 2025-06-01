#!/usr/bin/env ruby
# Chapter 8: Mini Project - Weather App

require 'net/http'
require 'uri'
require 'json'
require 'date'

class WeatherApp
  API_BASE_URL = "https://api.openweathermap.org/data/2.5"
  
  attr_reader :api_key, :default_location, :units
  
  def initialize(api_key, default_location = "London", units = "metric")
    @api_key = api_key
    @default_location = default_location
    @units = units  # metric (Celsius) or imperial (Fahrenheit)
    @cache = {}
    @cache_expiry = {}
  end
  
  # Get current weather for a location
  def current_weather(location = default_location)
    endpoint = "/weather"
    cache_key = "current_#{location}_#{units}"
    
    # Return cached data if available and not expired
    if cached_data_valid?(cache_key)
      return @cache[cache_key]
    end
    
    params = {
      q: location,
      units: units,
      appid: api_key
    }
    
    response = make_api_request(endpoint, params)
    
    if response["cod"] == 200
      # Extract and format the relevant weather information
      weather_data = {
        location: "#{response["name"]}, #{response["sys"]["country"]}",
        description: response["weather"][0]["description"],
        temperature: response["main"]["temp"],
        feels_like: response["main"]["feels_like"],
        humidity: response["main"]["humidity"],
        wind_speed: response["wind"]["speed"],
        wind_direction: wind_direction(response["wind"]["deg"]),
        clouds: response["clouds"]["all"],
        sunrise: Time.at(response["sys"]["sunrise"]),
        sunset: Time.at(response["sys"]["sunset"]),
        timestamp: Time.now
      }
      
      # Cache the data for 30 minutes
      cache_data(cache_key, weather_data, 30 * 60)
      
      weather_data
    else
      raise "API Error: #{response["message"]}"
    end
  end
  
  # Get 5-day forecast for a location
  def forecast(location = default_location, days = 5)
    endpoint = "/forecast"
    cache_key = "forecast_#{location}_#{units}_#{days}"
    
    # Return cached data if available and not expired
    if cached_data_valid?(cache_key)
      return @cache[cache_key]
    end
    
    params = {
      q: location,
      units: units,
      appid: api_key
    }
    
    response = make_api_request(endpoint, params)
    
    if response["cod"] == "200"
      # Group forecast data by day
      daily_forecasts = {}
      
      response["list"].each do |forecast|
        date = Time.at(forecast["dt"]).strftime("%Y-%m-%d")
        
        daily_forecasts[date] ||= {
          date: Date.parse(date),
          temperature_min: Float::INFINITY,
          temperature_max: -Float::INFINITY,
          descriptions: []
        }
        
        # Update min/max temperatures
        daily_forecasts[date][:temperature_min] = [daily_forecasts[date][:temperature_min], forecast["main"]["temp_min"]].min
        daily_forecasts[date][:temperature_max] = [daily_forecasts[date][:temperature_max], forecast["main"]["temp_max"]].max
        
        # Add weather description if not already included
        description = forecast["weather"][0]["description"]
        daily_forecasts[date][:descriptions] << description unless daily_forecasts[date][:descriptions].include?(description)
      end
      
      # Format the result and limit to requested number of days
      result = {
        location: "#{response["city"]["name"]}, #{response["city"]["country"]}",
        forecast: daily_forecasts.values.sort_by { |f| f[:date] }.first(days),
        timestamp: Time.now
      }
      
      # Cache the data for 1 hour
      cache_data(cache_key, result, 60 * 60)
      
      result
    else
      raise "API Error: #{response["message"]}"
    end
  end
  
  # Get air pollution data for a location
  def air_pollution(location = default_location)
    # First, get coordinates for the location
    weather = current_weather(location)
    
    endpoint = "/air_pollution"
    cache_key = "air_#{location}"
    
    # Return cached data if available and not expired
    if cached_data_valid?(cache_key)
      return @cache[cache_key]
    end
    
    # Get coordinates from the weather response
    coordinates = coordinates_for_location(location)
    
    params = {
      lat: coordinates[:lat],
      lon: coordinates[:lon],
      appid: api_key
    }
    
    response = make_api_request(endpoint, params)
    
    if response["list"]
      pollution_data = response["list"][0]
      
      result = {
        location: weather[:location],
        aqi: pollution_data["main"]["aqi"],  # Air Quality Index (1-5)
        components: {
          co: pollution_data["components"]["co"],      # Carbon monoxide
          no: pollution_data["components"]["no"],      # Nitrogen monoxide
          no2: pollution_data["components"]["no2"],    # Nitrogen dioxide
          o3: pollution_data["components"]["o3"],      # Ozone
          so2: pollution_data["components"]["so2"],    # Sulphur dioxide
          pm2_5: pollution_data["components"]["pm2_5"],  # Fine particles
          pm10: pollution_data["components"]["pm10"]   # Coarse particles
        },
        timestamp: Time.now
      }
      
      # Add text description of air quality
      result[:quality] = case result[:aqi]
                         when 1 then "Good"
                         when 2 then "Fair"
                         when 3 then "Moderate"
                         when 4 then "Poor"
                         when 5 then "Very Poor"
                         else "Unknown"
                         end
      
      # Cache the data for 1 hour
      cache_data(cache_key, result, 60 * 60)
      
      result
    else
      raise "API Error: Unable to retrieve air pollution data"
    end
  end
  
  # Display current weather in a readable format
  def display_current_weather(location = default_location)
    begin
      weather = current_weather(location)
      
      unit_symbol = units == "metric" ? "°C" : "°F"
      wind_unit = units == "metric" ? "m/s" : "mph"
      
      puts "===== Current Weather ====="
      puts "Location: #{weather[:location]}"
      puts "Updated: #{weather[:timestamp].strftime("%Y-%m-%d %H:%M:%S")}"
      puts "------------------------------"
      puts "Conditions: #{weather[:description].capitalize}"
      puts "Temperature: #{weather[:temperature].round(1)}#{unit_symbol}"
      puts "Feels Like: #{weather[:feels_like].round(1)}#{unit_symbol}"
      puts "Humidity: #{weather[:humidity]}%"
      puts "Wind: #{weather[:wind_speed]} #{wind_unit} #{weather[:wind_direction]}"
      puts "Cloud Cover: #{weather[:clouds]}%"
      puts "Sunrise: #{weather[:sunrise].strftime("%H:%M")}"
      puts "Sunset: #{weather[:sunset].strftime("%H:%M")}"
      puts "============================="
      
    rescue => e
      puts "Error: #{e.message}"
    end
  end
  
  # Display forecast in a readable format
  def display_forecast(location = default_location, days = 5)
    begin
      forecast_data = forecast(location, days)
      
      unit_symbol = units == "metric" ? "°C" : "°F"
      
      puts "===== #{days}-Day Forecast ====="
      puts "Location: #{forecast_data[:location]}"
      puts "Updated: #{forecast_data[:timestamp].strftime("%Y-%m-%d %H:%M:%S")}"
      puts "------------------------------"
      
      forecast_data[:forecast].each do |day|
        puts day[:date].strftime("%A, %b %d") # e.g., "Monday, Jan 01"
        puts "  Temperature: #{day[:temperature_min].round(1)}#{unit_symbol} to #{day[:temperature_max].round(1)}#{unit_symbol}"
        puts "  Conditions: #{day[:descriptions].join(", ")}"
        puts "------------------------------"
      end
      
      puts "============================="
      
    rescue => e
      puts "Error: #{e.message}"
    end
  end
  
  # Display air pollution data in a readable format
  def display_air_pollution(location = default_location)
    begin
      pollution = air_pollution(location)
      
      puts "===== Air Quality ====="
      puts "Location: #{pollution[:location]}"
      puts "Updated: #{pollution[:timestamp].strftime("%Y-%m-%d %H:%M:%S")}"
      puts "------------------------------"
      puts "Air Quality: #{pollution[:quality]} (Index: #{pollution[:aqi]}/5)"
      puts "Components:"
      puts "  CO: #{pollution[:components][:co]} μg/m³"
      puts "  NO₂: #{pollution[:components][:no2]} μg/m³"
      puts "  O₃: #{pollution[:components][:o3]} μg/m³"
      puts "  SO₂: #{pollution[:components][:so2]} μg/m³"
      puts "  PM2.5: #{pollution[:components][:pm2_5]} μg/m³"
      puts "  PM10: #{pollution[:components][:pm10]} μg/m³"
      puts "============================="
      
    rescue => e
      puts "Error: #{e.message}"
    end
  end
  
  private
  
  def make_api_request(endpoint, params)
    uri = URI("#{API_BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(params)
    
    begin
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        { "cod" => response.code, "message" => "HTTP Error: #{response.message}" }
      end
    rescue => e
      { "cod" => 500, "message" => "Request Error: #{e.message}" }
    end
  end
  
  def coordinates_for_location(location)
    weather = current_weather(location)
    
    # If we already have the coordinates from a previous request, use them
    # Otherwise, we need to make a geocoding request
    # For simplicity, we'll use a cache file
    
    # Sample implementation - in a real app, would fetch from the API response
    {
      lat: 51.5074, # Default to London
      lon: -0.1278
    }
  end
  
  def wind_direction(degrees)
    directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    index = ((degrees + 11.25) % 360) / 22.5
    directions[index.to_i]
  end
  
  def cache_data(key, data, expiry_seconds)
    @cache[key] = data
    @cache_expiry[key] = Time.now + expiry_seconds
  end
  
  def cached_data_valid?(key)
    @cache.key?(key) && @cache_expiry.key?(key) && Time.now < @cache_expiry[key]
  end
end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  # Replace with your actual API key
  api_key = "YOUR_OPENWEATHERMAP_API_KEY"
  
  if api_key == "YOUR_OPENWEATHERMAP_API_KEY"
    puts "Please update the script with your actual OpenWeatherMap API key."
    puts "Sign up at: https://openweathermap.org/api"
    exit
  end
  
  # Create weather app instance
  weather_app = WeatherApp.new(api_key)
  
  # Command-line interface
  if ARGV.empty?
    puts "Ruby Weather App"
    puts "----------------"
    puts "Usage: ruby weather_app.rb [command] [location]"
    puts ""
    puts "Commands:"
    puts "  current [location]  - Get current weather (default: London)"
    puts "  forecast [location] - Get 5-day forecast (default: London)"
    puts "  air [location]      - Get air quality data (default: London)"
    puts "  all [location]      - Get all weather data (default: London)"
    puts ""
    puts "Examples:"
    puts "  ruby weather_app.rb current 'New York'"
    puts "  ruby weather_app.rb forecast Tokyo"
    puts "  ruby weather_app.rb air Paris"
    puts ""
    puts "Displaying default current weather for London:"
    puts ""
    weather_app.display_current_weather
  else
    command = ARGV[0].downcase
    location = ARGV[1] || "London"
    
    case command
    when "current"
      weather_app.display_current_weather(location)
    when "forecast"
      weather_app.display_forecast(location)
    when "air"
      weather_app.display_air_pollution(location)
    when "all"
      weather_app.display_current_weather(location)
      puts ""
      weather_app.display_forecast(location)
      puts ""
      weather_app.display_air_pollution(location)
    else
      puts "Unknown command: #{command}"
      puts "Available commands: current, forecast, air, all"
    end
  end
end
