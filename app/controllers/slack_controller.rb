class SlackController < ApplicationController
  def player_ranking
    @player = Player.where("name LIKE '%?%'", params[:text])
  end
end
