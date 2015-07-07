require "forwardable"

class Roda
  module RodaPlugins
    module UploadedFile
      module RequestMethods
        def params
          @_params ||= params_with_uploaded_file(super)
        end

        private

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

      class UploadedFile
        attr_reader :original_filename, :content_type, :headers

        def initialize(hash)
          @tempfile          = hash.fetch(:tempfile)
          @original_filename = hash[:filename]
          @content_type      = hash[:type]
          @headers           = hash[:head]
        end

        def to_io
          @tempfile
        end

        extend Forwardable
        delegate [:read, :open, :close, :path, :rewind, :size, :eof?] => :@tempfile
      end
    end

    register_plugin(:uploaded_file, UploadedFile)
  end
end
