require "kvizovi/finders/base_finder"

module Kvizovi
  module Finders
    class GameplayFinder < BaseFinder
      def search(user:, as:, quiz_id: nil, page: nil, **)
        gameplays = send("all_for_#{as}", user)
        gameplays = gameplays.where(quiz_id: quiz_id) if quiz_id
        gameplays = new(gameplays).paginate(page) if page
        gameplays.reverse(:started_at)
      end

      def find(id)
        find_by_id(id)
      end

      private

      def all_for_creator(user)
        dataset.where(quiz: user.quizzes_dataset)
      end

      def all_for_player(user)
        dataset.where(players: user)
      end
    end
  end
end
