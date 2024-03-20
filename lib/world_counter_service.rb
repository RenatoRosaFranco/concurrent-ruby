# frozen_string_literal: true

require_relative './../config/logger.rb'

class WorldCounterService < Object
	def self.call(file)
		world_count ||= count_words_on_file(file)
		$log.info("#{self.class.to_s} excecuted with success.")
		
		world_count
	rescue StandardError => e
		$log.error("Failed to count words on file #{e.message}")
	end

	private_class_method def self.count_words_on_file(file)
		count = 0
		File.open(file).each_line do |line|
			count += line.split.count
		end
		count
	end
end
