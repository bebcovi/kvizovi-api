require "forwardable"

class Roda
  module RodaPlugins
    # The uploaded_file plugin transforms request params in a way that it
    # replaces Rack's Hash representation of an uploaded file
    #
    #   request.params
    #   #=> {"image" =>
    #         {:filename => "image.jpg",
    #          :type     => "image/jpeg",
    #          :tempfile => #<File:/var/folders/k7/6zx6dx6x7ys3rv3srh0nyfj00000gn/T/RackMultipart20150708-55947-rt2y5x.jpg>,
    #          :head     => "..."}
    #
    # with an IO object
    #
    #   request.params
    #   #=> {"image" => #<Roda::RodaPlugins::UploadedFile::UploadedFile:0x007ff5f5c33848 @tempfile=#<Tempfile:/var/folders/k7/6zx6dx6x7ys3rv3srh0nyfj00000gn/T/upload20150708-56562-1rh6cjd>, @original_filename="foo.jpg", @content_type="text/plain", @headers="...">}
    #
    #   file = request.params["image"]
    #   file.filename     #=> "image.jpg"
    #   file.content_type #=> "image/jpeg"
    #   file.tempfile     #=> #<File:/var/folders/k7/6zx6dx6x7ys3rv3srh0nyfj00000gn/T/RackMultipart20150708-55947-rt2y5x.jpg>
    #   file.headers      #=> "..."
    #
    # This plugin makes using uploading libraries in Roda more convenient.
    module UploadedFile
      module RequestMethods
        def params
          @_params ||= params_with_uploaded_file(super)
        end

        private

        # We recursively search through params, and replace any Rack's upload
        # hash with an instance of UploadedFile.
        def params_with_uploaded_file(params)
          case params
          when Hash
            if params.key?(:tempfile)
              UploadedFile.new(params)
            else
              hash = {}
              params.each { |k, v| hash[k] = params_with_uploaded_file(v) }
              hash
            end
          when Array
            params.map { |x| params_with_uploaded_file(x) }
          else
            params
          end
        end
      end

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

    register_plugin(:uploaded_file, UploadedFile)
  end
end
