class SlackController < ApplicationController
  before_action :find_game
  rescue_from Player::PlayerNotFoundError, with: :player_not_found

  def player_ranking
    @player = Player.find_by_name params[:text]
    @ratings = @player.ratings.find_by_game_id(@game)
  end

  def record_result
    first_player, _, second_player = params[:text].split(' ')
    @first_player = Player.find_by_name first_player
    @second_player = Player.find_by_name second_player
    result = { teams: {
        '0' => {
          players: @first_player.id,
          relation: :defeats
        },
        '1' => {
          players: @second_player.id
        }
      }
    }
    ResultService.create(@game, result)
  end

  private

  def find_game
    # Always pingpong, for now
    @game = Game.find(1)
  end

  def player_not_found(error)
    @name = error.name
    render 'slack/player_not_found'
  end
end
