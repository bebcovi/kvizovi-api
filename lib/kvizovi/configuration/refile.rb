require "refile"
require "refile/image_processing"
require "refile/sequel"

require "tmpdir"

Refile.cache = Refile::Backend::FileSystem.new(Dir.tmpdir)
Refile.store = Refile::Backend::FileSystem.new(Dir.tmpdir)

Refile::Sequel::Attachment.prepend Module.new {
  def attachment(name, **options)
    super

    ancestors[1].class_eval do
      define_method(:"#{name}=") do |value|
        value = value[:tempfile] if value.is_a?(Hash)
        send("#{name}_attacher").set(value)
      end

      define_method(:"#{name}_url") do
        url = Refile.attachment_url(self, name, :fit, "*", "*")
        url = url.sub("*", "{width}").sub("*", "{height}") if url
        url
      end
    end
  end
}
