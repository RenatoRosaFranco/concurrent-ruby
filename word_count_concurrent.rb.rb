# frozen_string_literal: true

require 'thread'
require 'benchmark'

require_relative 'lib/file_generator_service'
require_relative 'lib/world_counter_service'

# Generate files if files directory is empty
FileGeneratorService.call if Dir.glob('files/*.txt').empty?

file_paths = Dir.glob('files/*.txt')

# Hash to stores the result of word count per file
results = {}

# Creates a mutex to controll hash access data
mutex = Mutex.new

threads = []

realtime = Benchmark.realtime do
  file_paths.sort.each do |path|
    threads << Thread.new(path) do |file_path|
      word_count_result = WorldCounterService.call(file_path)
      mutex.synchronize do
        results[file_path] = word_count_result
      end
    end
  end
end

puts "\nProcess time: #{realtime.ceil}"
puts "Checked a total of #{file_paths.count} files."

# Wait for all threads to complete
threads.each(&:join)

# Output the results
results.each do |file_path, count|
	puts "#{file_path}: #{count} palavras"
end
