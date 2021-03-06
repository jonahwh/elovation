module Slack
  module Decorators
    class RatingDecorator
      def initialize(player, previous_rating, game)
        @player = player
        @previous_rating = previous_rating
        @game = game
      end

      def message
        "<#{player_url}|#{@player.name}>: #{ranking_emoji} *#{ordinalized_ranking(ranking)}* (#{rating} pts) [#{rating_change} pts from #{ordinalized_ranking(old_ranking)} (#{old_rating} pts)]"
      end

      def player_url
        Rails.application.routes.url_helpers.player_url(@player.id, host: ENV['HOST'])
      end

      def ranking
        @game.ranking_for(@player)
      end

      def rating
        @player.rating_for(@game)
      end

      def old_rating
        @previous_rating[:rating]
      end

      def old_ranking
        @previous_rating[:ranking]
      end

      def rating_change
        change = (rating - (Integer(old_rating) rescue 0))
        return "+#{change}" if change > 0
        return change
      end

      def ranking_emoji
        if old_ranking == 'NR' || old_ranking > ranking
          ':uptoplan:'
        elsif old_ranking == ranking
          ':flattoplan:'
        else
          ':downtoplan:'
        end
      end

      def rating_emoji
        if old_rating == 'NR' || old_rating < rating
          ':uptoplan:'
        elsif old_rating == rating
          ':flattoplan:'
        else
          ':downtoplan:'
        end
      end

      private

      def ordinalized_ranking(ranking)
        Integer(ranking).ordinalize rescue ranking
      end
    end
  end
end
