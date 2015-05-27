require "base64"

module Kvizovi
  class Authorization
    def self.strategies
      [:basic, :token]
    end

    def initialize(header)
      @header = header
    end

    def present?
      !!@header
    end

    strategies.each do |name|
      define_method(name) do
        strategy(name).get or raise Kvizovi::Error::Unauthorized, :"#{name}_missing"
      end

      define_method("#{name}?") do
        strategy(name).present?
      end
    end

    def value
      strategies.each { |strategy| return strategy.get if strategy.present? }
      raise Kvizovi::Error::Unauthorized, :authorization_missing
    end

    private

    def strategy(name)
      self.class.const_get(name.capitalize).new(@header)
    end

    def strategies
      self.class.strategies.map { |name| strategy(name) }
    end

    Token = Struct.new(:header) do
      def get
        header.to_s[/^Token token="(\w+)"/, 1]
      end

      def present?
        /^Token/ === header.to_s
      end
    end

    Basic = Struct.new(:header) do
      def get
        base64 = header.to_s[/^Basic (\w+)/, 1]
        Base64.decode64(base64).split(":")
      end

      def present?
        /^Basic/ === header.to_s
      end
    end
  end
end
