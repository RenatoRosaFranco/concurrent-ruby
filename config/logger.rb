# frozen_string_literal: true

require 'logger'

Dir.mkdir('log') unless Dir.exist?('log')

$log = Logger.new("log/application.log", 'daily')
$log.level = Logger::INFO
$log.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime}: [#{severity}] #{msg}\n"
end
