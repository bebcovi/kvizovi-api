require "refile"
require "refile/mini_magick"
require "refile/sequel"

require "securerandom"

Refile.secret_key = SecureRandom.hex(36)

if ENV["RACK_ENV"] == "production"

  require "refile/s3"
  require "kvizovi/configuration/credentials"

  aws = {
    access_key_id:     ENV.fetch("AMAZON_S3_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("AMAZON_S3_SECRET_ACCESS_KEY"),
    region:            ENV.fetch("AMAZON_S3_REGION"),
    bucket:            ENV.fetch("AMAZON_S3_BUCKET"),
  }

  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)

else

  require "tmpdir"

  Refile.cache = Refile::Backend::FileSystem.new(Dir.tmpdir)
  Refile.store = Refile::Backend::FileSystem.new("public/uploads")

end
