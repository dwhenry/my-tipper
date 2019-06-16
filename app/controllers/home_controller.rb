class HomeController < ApplicationController
  # before_action :authenticate_user!

  def index
    if event == '2019' && current_user
      # ensure the user is in the current event as soon as they log in (hack)
      league = League.find_or_create_by!(name: 'All players', event: true, public: true).id
      Player.find_or_create_by!(user: current_user, league_id: league)
    end
  end
end
