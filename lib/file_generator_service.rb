# frozen_string_literal: true

require 'ffaker'

class FileGeneratorService < Object
	def self.call
		generate_files
	end

	private_class_method def self.generate_files
		Dir.mkdir('files') unless Dir.exist?('files')
		
		(1..100).each do |index|
			File.write(
				"files/file#{index}.txt", 
				FFaker::Lorem.paragraphs(rand(8..12)).join
			)
		end
	end
end
