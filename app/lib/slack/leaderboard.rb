module Slack
  class Leaderboard
    def self.show(payload)
      game = Game.find(payload['actions'][0]['selected_options'][0]['value'])
      ratings = if game.active?
                  game.all_ratings.includes(:player, player: [:results]).select(&:active?) if game.active?
                else
                  game.all_ratings.includes(:player, player: [:results])
                end
      rows = ratings.map.with_index(1) do |rating, index|
        rankings_with_size = rating.player.results.for_game(rating.game).includes(:teams, teams: [:players]).map { |game| { size: game.teams.size, rank: game.teams.find { |team| team.players.first == rating.player }.rank } }

        rankings = rankings_with_size.map { |r| r[:rank] }
        average_ranking = rankings.reduce(:+).to_f / rankings.size

        percentiles = rankings_with_size.map { |r| r[:rank].to_f / r[:size] }
        average_percentiles = percentiles.reduce(:+).to_f / rankings.size

        [index, rating.player.name, rating.value, rating.player.total_wins(rating.game), rating.player.results.for_game(rating.game).losses.size, average_ranking.round(1), (average_percentiles * 100).round(0).ordinalize]
      end
      game_url = Rails.application.routes.url_helpers.game_url(game, host: ENV['HOST'])
      message = "```\n#{Terminal::Table.new :title => "#{game.name} Leaderboard", :headings => %w(# Name Ranking W L Average\ Ranking Average\ Percentile), :rows => rows}\n```\n<#{game_url}|More Details>"
      slack_client = Slack::Web::Client.new(token: SlackAuthorization.find_by(team_id: payload['team']['id']).access_token)
      slack_client.chat_postMessage(channel: payload['channel']['id'], text: message)
    end
  end
end
