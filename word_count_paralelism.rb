# frozen_string_literal: true

require 'erb'
require 'benchmark'
require 'parallel'
require 'yaml'

# Set configuration
config_path = File.join(File.dirname(__FILE__), 'config', 'application.yaml')
config = YAML.load(ERB.new(File.read(config_path)).result)

require_relative 'lib/file_generator_service'
require_relative 'lib/world_counter_service'

# Generate files if files directory is empty
FileGeneratorService.call if Dir.glob('files/*.txt').empty?

results = nil
file_paths = Dir.glob(config['files_directory'])

realtime = Benchmark.realtime do
  results = Parallel.map(file_paths, in_processes: config['thread_pool']['max_threads']) do |file_path|
    [file_path, WorldCounterService.call(file_path)]
  end.to_h
end

puts "\n-- Analytics --\n\n"
puts "Process time: #{realtime.ceil}"
puts "Checked a total of (#{file_paths.count}) files. \n\n"
puts "---\n\n"

# Output the results
results.each do |file_path, count|
	puts "#{file_path}: #{count} palavras"
end
