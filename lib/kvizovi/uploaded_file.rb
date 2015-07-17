require "forwardable"

module Kvizovi
  # Represents the uploaded file that acts as an IO object, containing the
  # extra information from Rack's upload hash.
  class UploadedFile
    attr_reader :tempfile, :original_filename, :content_type, :headers

    def initialize(hash)
      @tempfile          = hash.fetch(:tempfile)
      @original_filename = hash[:filename]
      @content_type      = hash[:type]
      @headers           = hash[:head]
    end

    alias to_io tempfile

    extend Forwardable
    delegate [:read, :open, :close, :path, :rewind, :size, :eof?] => :@tempfile
  end
end
