ENV["RACK_ENV"] = "test"

def benchmark(name = nil)
  time = Time.now
  result = yield
  puts "#{name} (#{Time.now - time})"
  result
end

require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "minitest/hooks"
