# frozen_string_literal: true

require 'thread'
require 'concurrent'
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
results = Concurrent::Map.new

# Creates a mutex to controll hash access data
mutex = Mutex.new

# Creates a pool de threads com um tamanho máximo
thread_pool_config = config['thread_pool']

pool = Concurrent::ThreadPoolExecutor.new(
  min_threads: thread_pool_config['min_threads'],
  max_threads: thread_pool_config['max_threads'],
  max_queue: thread_pool_config['max_queue'],
  fallback_policy: :caller_runs
)

realtime = Benchmark.realtime do
  file_batches.each do |batch|
    pool.post do
      batch_results = batch.map do |file_path|
        [file_path, WorldCounterService.call(file_path)]
      end.to_h

      mutex.synchronize { results.merge!(batch_results) }
    end
  end

  pool.shutdown
  pool.wait_for_termination
end

puts "\n-- Analytics --\n\n"
puts "Process time: #{realtime.ceil}"
puts "Checked a total of (#{file_paths.count}) files. \n\n"
puts "---\n\n"

# Output the results
results.each do |file_path, count|
	puts "#{file_path}: #{count} palavras"
end
