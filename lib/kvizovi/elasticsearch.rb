require "elasticsearch"

module Kvizovi
  module ElasticsearchIndex
    class << self
      attr_accessor :noop, :refresh
    end

    def self.index_name
      "kvizovi".freeze
    end

    def self.[](mapping_name)
      mappings[mapping_name] or raise "undefined mapping #{mapping_name.inspect}"
    end

    def self.mappings
      unless noop
        {quiz: QuizMapping.new(self)}
      else
        Hash.new { NullMapping.new(self) }
      end
    end

    def self.create!
      delete!
      client.indices.create(index: index_name) unless noop
    end

    def self.delete!
      client.indices.delete(index: index_name) if exists? && !noop
    end

    def self.exists?
      client.indices.exists?(index: index_name) unless noop
    end

    def self.clear
      mappings.each_value { |mapping| mapping.delete_all }
    end

    def self.client
      @client ||= Elasticsearch::Client.new
    end

    class Mapping
      def self.type_name(name = nil)
        if name
          @type_name = name
        else
          @type_name or raise "#{self}.type_name has not been set"
        end
      end

      def initialize(index)
        @index = index
      end

      def index(objects)
        return if Array(objects).empty?
        client.bulk index: index_name, type: type_name, refresh: refresh?,
          body: serialize(objects).map { |document|
            {index: {_id: document.fetch(:id), data: document}}
          }
      end

      def delete(objects)
        return if Array(objects).empty?
        client.bulk index: index_name, type: type_name, refresh: refresh?,
          body: serialize(objects).map { |document|
            {delete: {_id: document.fetch(:id)}}
          }
      end

      def delete_all
        client.delete_by_query index: index_name, type: type_name, q: "*"
      end

      def search(query)
        search_options =
          case query
          when String then {q: query}
          when Hash   then {body: {query: query}}
          end

        results = client.search index: index_name, type: type_name, **search_options
        results["hits"]["hits"].map { |hash| hash["_source"] }
      end

      def serialize(objects)
        Array(objects).map { |object| send("serialize_#{type_name}", object) }
      end

      private

      def refresh?
        @index.refresh
      end

      def type_name
        self.class.type_name
      end

      def index_name
        @index.index_name
      end

      def client
        @index.client
      end
    end

    class QuizMapping < Mapping
      type_name "quiz"

      def search(query)
        super(
          query_string: {
            query: query,
            fields: [
              "name^4",
              "questions.title^3",
              "questions.content^2",
              "creator.name^3",
            ],
          }
        )
      end

      private

      def serialize_quiz(quiz)
        {
          id:        quiz.id,
          name:      quiz.name,
          questions: serialize_questions(quiz.questions),
          creator:   serialize_creator(quiz.creator),
        }
      end

      def serialize_questions(questions)
        questions.map do |question|
          {
            title: question.title,
            content: question.content.to_s,
          }
        end
      end

      def serialize_creator(user)
        {
          name: user.name,
        }
      end
    end

    class NullMapping < Mapping
      def index(*)
      end

      def delete(*)
      end

      def delete_all(*)
      end

      def search(*)
        []
      end
    end
  end
end
