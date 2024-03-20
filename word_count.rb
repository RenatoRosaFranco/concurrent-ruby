# frozen_string_literal: true

require 'erb'
require 'benchmark'
require 'yaml'

# Set configuration
config_path = File.join(File.dirname(__FILE__), 'config', 'application.yaml')
config = YAML.load(ERB.new(File.read(config_path)).result)

require_relative 'lib/file_generator_service'
require_relative 'lib/world_counter_service'

# Generate files if the files directory is empty
FileGeneratorService.call if Dir.glob(config['files_directory']).empty?

file_paths = Dir.glob(config['files_directory'])

# Hash to store the result of word count per file
results = {}

realtime = Benchmark.realtime do
  file_paths.each do |file_path|
    results[file_path] = WorldCounterService.call(file_path)
  end
end

puts "\n-- Analytics --\n\n"
puts "Process time: #{realtime.ceil} seconds"
puts "Checked a total of #{file_paths.count} files. \n\n"
puts "---\n\n"

# Output the results
results.each do |file_path, count|
  puts "#{file_path}: #{count} words"
end