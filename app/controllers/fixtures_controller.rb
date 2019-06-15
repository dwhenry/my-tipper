class FixturesController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show]

  def index
    @fixtures = Fixture.where(event: event).includes({home: :team}, {away: :team}).order(:at)
  end

  def create
    params[:fixtures].each do |fixture, value|
      next if value.blank? || value.to_i == 0

      fixture_id = fixture.split('_').last.to_i

      Fixture.find(fixture_id).update_result(value.to_i)
    end
    redirect_to fixtures_path(paramify)
  end

  def show
    @fixture = Fixture.find(params[:id])
    users = League.find_by!(name: params[:league] || event).users.all

    @points = Fixture.where(event: @fixture.event, picks: {user_id: users.map(&:id)}).where(['fixtures.at <= ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')
    @prev_points = Fixture.where(event: @fixture.event, picks: {user_id: users.map(&:id)}).where(['fixtures.at < ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')
  end
end
