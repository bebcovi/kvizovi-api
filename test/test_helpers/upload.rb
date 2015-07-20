require "tmpdir"

module TestHelpers
  module Upload
    def around_all
      if defined?(Refile)
        Dir.mktmpdir("refile") do |tmpdir|
          Refile.cache = Refile::Backend::FileSystem.new(tmpdir)
          Refile.store = Refile::Backend::FileSystem.new(tmpdir)
          super
        end
      else
        super
      end
    end
  end
end
