class SlackController < ApplicationController
  def player_ranking
    # Always pingpong, for now
    @game = Game.find(1)
    @player = Player.where('LOWER(name) LIKE ?', "%#{params[:text].downcase}%").first
  end
end
