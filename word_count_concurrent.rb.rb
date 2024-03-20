# frozen_string_literal: true

require 'thread'
require 'benchmark'
require 'yaml'

# Set configuration
config_path = File.join(File.dirname(__FILE__), 'config', 'application.yaml')
config = YAML.load_file(config_path)

require_relative 'lib/file_generator_service'
require_relative 'lib/world_counter_service'

# Generate files if files directory is empty
FileGeneratorService.call if Dir.glob('files/*.txt').empty?

file_paths = Dir.glob(config['files_directory'])
file_batches = file_paths.each_slice(config['batch_size']).to_a

# Hash to stores the result of word count per file
results = {}

# Creates a mutex to controll hash access data
mutex = Mutex.new

threads = []

realtime = Benchmark.realtime do
  file_batches.each do |batch|
    threads << Thread.new(batch) do |files|
      batch_results = files.map do |file_path|
        [file_path, WorldCounterService.call(file_path)]
      end.to_h

      mutex.synchronize do
        results.merge!(batch_results)
      end
    end
  end
end

puts "\n-- Analytics --\n\n"
puts "Process time: #{realtime.ceil}"
puts "Checked a total of (#{file_paths.count}) files. \n\n"
puts "---\n\n"

# Wait for all threads to complete
threads.each(&:join)

# Output the results
results.each do |file_path, count|
	puts "#{file_path}: #{count} palavras"
end
