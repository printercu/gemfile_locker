# frozen_string_literal: true

module GemfileLocker
  class FileEditor
    attr_reader :path, :processor

    def initialize(path, processor)
      @path = path
      @processor = processor
    end

    def run
      write
    end

    def source
      @source ||= File.read(path)
    end

    def result
      @result ||= processor.call(source)
    end

    def write
      File.write(path, result)
    end
  end
end
