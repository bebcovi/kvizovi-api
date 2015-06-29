module TestHelpers
  module Profiling
    def benchmark(name = nil)
      time = Time.now
      result = yield
      puts "#{name} (#{Time.now - time})"
      result
    end
    alias bench benchmark

    def profile(&block)
      require "ruby-prof"
      result = RubyProf.profile(&block)
      printer = RubyProf::CallStackPrinter.new(result)
      File.open("profile.html", "w") { |file| printer.print(file) }
    end
  end
end
