require "refile"
require "refile/mini_magick"
require "refile/sequel"

require "tmpdir"

Refile.cache = Refile::Backend::FileSystem.new(Dir.tmpdir)
Refile.store = Refile::Backend::FileSystem.new(Dir.tmpdir)
