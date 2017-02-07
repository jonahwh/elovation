class SlackController < ApplicationController
  def player_ranking
    @player = Player.find(params[:text])
  end
end
