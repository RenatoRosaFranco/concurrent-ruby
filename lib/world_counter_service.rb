# frozen_string_literal: true

class WorldCounterService
	def self.call(file)
		count_words_on_file(file)
	rescue Exception => e
		puts "Failed to count words on file #{e.message}"
	end

	private_class_method def self.count_words_on_file(file)
		count = 0
		File.open(file).each_line do |line|
			count += line.split.count
		end
		count
	end
end
