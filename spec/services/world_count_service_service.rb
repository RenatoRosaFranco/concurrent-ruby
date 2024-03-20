# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/world_counter_service'

RSpec.describe WorldCounterService do
  describe '.call' do
    let(:test_file_path) { 'spec/fixtures/test_file.txt' }
    let(:content) { 'Hello world\nThis is a test\n' }

    before do
      File.write(test_file_path, content)
    end

    after do
      File.delete(test_file_path)
    end

    it 'counts the words in a file' do
      expect(described_class.call(test_file_path)).to eq(5)
    end

    context 'when an error occurs' do
      before do
        allow(File).to receive(:open).and_raise(StandardError, 'fake error')
      end
    
      it 'logs an error message' do
        expect($log).to receive(:error).with(/Failed to count words on file fake error/)
        expect { described_class.call(test_file_path) }.not_to raise_error
      end
    end
  end
end