class FixturesController < ApplicationController
  def index
    @fixtures = Fixture.where(event: event).includes({home: :team}, {away: :team}).order(:at)
  end

  def show
    @fixture = Fixture.find(params[:id])
    league = League.find_by(name: params[:league])
    @users = league ? league.users.all : Pick.includes(:fixture, :user).where.not(pick: 0).where(fixtures: { event: event }).map(&:user).uniq

    scope = Fixture.where(event: @fixture.event, picks: {user_id: @users.map(&:id)}).includes(:picks).group(:user_id)
    @points = scope.where(['fixtures.at <= ?', @fixture.at]).order('sum(picks.score)').sum('picks.score')
    @prev_points = scope.where(['fixtures.at < ?', @fixture.at]).order('sum(picks.score)').sum('picks.score')
  end
end
