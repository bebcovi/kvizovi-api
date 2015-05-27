require "kvizovi/mediators/gameplays"

module Kvizovi
  class App
    route "gameplays" do |r|
      r.is do
        r.post do
          Mediators::Gameplays.create(resource(:gameplay))
        end

        r.get do
          required(:as)
          Mediators::Gameplays.new(current_user).search(params)
        end
      end

      r.is ":id" do |gameplay_id|
        r.get do
          Mediators::Gameplays.new(current_user).find(gameplay_id)
        end
      end
    end
  end
end
