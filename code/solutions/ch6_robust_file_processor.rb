#!/usr/bin/env ruby
# Chapter 6: Mini Project - Robust File Processor

class FileProcessor
  attr_reader :log, :processed_files
  
  def initialize
    @log = []
    @processed_files = []
  end
  
  def process_file(filename, options = {})
    begin
      log_info("Starting to process file: #{filename}")
      
      # Check if file exists
      unless File.exist?(filename)
        raise Errno::ENOENT, "File not found: #{filename}"
      end
      
      # Check file extension
      validate_file_extension(filename, options[:allowed_extensions]) if options[:allowed_extensions]
      
      # Check file size
      validate_file_size(filename, options[:max_size]) if options[:max_size]
      
      # Process file contents
      content = File.read(filename)
      
      # Apply transformations if provided
      if options[:transformations] && options[:transformations].is_a?(Array)
        options[:transformations].each do |transformation|
          content = apply_transformation(content, transformation)
        end
      end
      
      # Write to output file if provided
      if options[:output_file]
        write_to_output(options[:output_file], content)
      end
      
      # Mark file as processed
      @processed_files << filename
      log_info("Successfully processed file: #{filename}")
      
      # Return processed content
      return content
      
    rescue Errno::ENOENT => e
      log_error("File not found error: #{e.message}")
      raise
    rescue InvalidFileExtensionError => e
      log_error("Invalid file extension: #{e.message}")
      raise
    rescue FileSizeTooLargeError => e
      log_error("File size error: #{e.message}")
      raise
    rescue => e
      log_error("Unexpected error while processing file: #{e.message}")
      raise
    end
  end
  
  def process_directory(directory, options = {})
    begin
      log_info("Starting to process directory: #{directory}")
      
      # Check if directory exists
      unless Dir.exist?(directory)
        raise Errno::ENOENT, "Directory not found: #{directory}"
      end
      
      # Get files in directory
      pattern = options[:pattern] || '*'
      files = Dir.glob(File.join(directory, pattern))
      
      if files.empty?
        log_warning("No files matching pattern '#{pattern}' found in directory: #{directory}")
        return []
      end
      
      # Process each file
      results = {}
      files.each do |file|
        begin
          next unless File.file?(file)
          results[file] = process_file(file, options)
        rescue => e
          results[file] = e
          log_warning("Skipping file due to error: #{file}")
          next if options[:continue_on_error]
          raise
        end
      end
      
      log_info("Finished processing directory: #{directory}")
      results
      
    rescue Errno::ENOENT => e
      log_error("Directory not found error: #{e.message}")
      raise
    rescue => e
      log_error("Unexpected error while processing directory: #{e.message}")
      raise
    end
  end
  
  def print_log
    @log.each do |entry|
      puts "#{entry[:timestamp]} [#{entry[:level]}] #{entry[:message]}"
    end
  end
  
  private
  
  def log_entry(level, message)
    entry = {
      timestamp: Time.now,
      level: level,
      message: message
    }
    @log << entry
    entry
  end
  
  def log_info(message)
    log_entry(:info, message)
  end
  
  def log_warning(message)
    log_entry(:warning, message)
  end
  
  def log_error(message)
    log_entry(:error, message)
  end
  
  def validate_file_extension(filename, allowed_extensions)
    extension = File.extname(filename).downcase[1..-1]
    unless allowed_extensions.include?(extension)
      raise InvalidFileExtensionError.new(
        "File '#{filename}' has invalid extension '.#{extension}'. " +
        "Allowed extensions: #{allowed_extensions.join(', ')}"
      )
    end
  end
  
  def validate_file_size(filename, max_size)
    file_size = File.size(filename)
    if file_size > max_size
      raise FileSizeTooLargeError.new(
        "File '#{filename}' is too large (#{file_size} bytes). " +
        "Maximum allowed size: #{max_size} bytes"
      )
    end
  end
  
  def apply_transformation(content, transformation)
    case transformation
    when :uppercase
      content.upcase
    when :lowercase
      content.downcase
    when :capitalize
      content.capitalize
    when :strip
      content.strip
    when Proc
      transformation.call(content)
    else
      content
    end
  end
  
  def write_to_output(output_file, content)
    # Create output directory if it doesn't exist
    output_dir = File.dirname(output_file)
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
    
    # Write content to output file
    File.write(output_file, content)
    log_info("Wrote output to file: #{output_file}")
  end
end

# Custom exceptions
class InvalidFileExtensionError < StandardError; end
class FileSizeTooLargeError < StandardError; end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  require 'fileutils'
  
  # Create test directory and files
  test_dir = "test_files"
  FileUtils.mkdir_p(test_dir)
  
  # Create test files
  File.write("#{test_dir}/sample1.txt", "This is a sample text file.\nIt has multiple lines.\n")
  File.write("#{test_dir}/sample2.txt", "Another sample file with some text.")
  File.write("#{test_dir}/data.csv", "id,name,age\n1,Alice,30\n2,Bob,25\n3,Charlie,35")
  File.write("#{test_dir}/invalid.xyz", "File with invalid extension")
  File.write("#{test_dir}/large.txt", "X" * 1024 * 10)  # 10KB file
  
  processor = FileProcessor.new
  
  puts "=== File Processor Demo ==="
  
  # Process a single file
  begin
    puts "\nProcessing a single text file..."
    content = processor.process_file("#{test_dir}/sample1.txt")
    puts "Content: #{content}"
  rescue => e
    puts "Error: #{e.message}"
  end
  
  # Process with transformations
  begin
    puts "\nProcessing file with transformations..."
    content = processor.process_file("#{test_dir}/sample1.txt", 
      transformations: [:uppercase, ->(text) { text.gsub(/\n/, ' ') }]
    )
    puts "Transformed content: #{content}"
  rescue => e
    puts "Error: #{e.message}"
  end
  
  # Try processing with invalid extension
  begin
    puts "\nTrying to process file with invalid extension..."
    processor.process_file("#{test_dir}/invalid.xyz", allowed_extensions: ['txt', 'csv'])
  rescue => e
    puts "Expected error: #{e.message}"
  end
  
  # Try processing file that's too large
  begin
    puts "\nTrying to process file that's too large..."
    processor.process_file("#{test_dir}/large.txt", max_size: 1024)  # 1KB limit
  rescue => e
    puts "Expected error: #{e.message}"
  end
  
  # Process all text files in directory
  begin
    puts "\nProcessing all text files in directory..."
    results = processor.process_directory(test_dir, 
      pattern: "*.txt",
      allowed_extensions: ['txt'],
      transformations: [:strip],
      continue_on_error: true
    )
    
    puts "Processed #{results.size} files:"
    results.each do |file, result|
      puts "- #{file}: #{result.is_a?(Exception) ? "Error: #{result.message}" : "Success"}"
    end
  rescue => e
    puts "Error: #{e.message}"
  end
  
  # Print the log
  puts "\n=== Processing Log ==="
  processor.print_log
  
  # Cleanup
  FileUtils.rm_rf(test_dir)
end
