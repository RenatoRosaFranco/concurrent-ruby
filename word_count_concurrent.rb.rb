# frozen_string_literal: true

require 'thread'
require 'benchmark'

require_relative 'lib/file_generator_service'

# Generate files if files directory is empty
FileGeneratorService.call if Dir.glob('files/*.txt').empty?

# Function that count the numbers of world per file
def word_count(file_path)
  count = 0
  File.open(file_path).each_line do |line|
    count += line.split.count
  end
  count
end

file_paths = Dir.glob('files/*.txt')

# Hash to stores the result of word count per file
results = {}

# Creates a mutex to controll hash access data
mutex = Mutex.new

threads = []

realtime = Benchmark.realtime do
  file_paths.sort.each do |path|
    threads << Thread.new(path) do |file_path|
      word_count_result = word_count(file_path)
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
