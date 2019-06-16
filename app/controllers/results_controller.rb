class ResultsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :current_admin

  def index
    fixtures = Fixture.includes({home: :team}, {away: :team}, :picks).order(:at)
    fixtures = fixtures.where(event: event)
    # fixtures = fixtures.where(['at < ?', Time.now.utc])
    fixtures = fixtures.all

    user_ids = League.find_by!(name: params[:league] || League::ALL_PLAYERS).users.pluck(:id)

    @rounds = {}
    results = Hash.new(nil)
    fixtures.each_with_index do |fixture, i|
      if fixture.result
        keys = results.keys
        fixture.picks.each do |pick|
          next unless user_ids.include?(pick.user_id)
          results[pick.user_id] ||= i * 20 # make up for missed rounds
          results[pick.user_id] += pick.score
          keys.delete(pick.user_id)
        end
        keys.each { |k| results[k] += 20 } # make up for missed round
        @rounds[fixture.id] = results.dup
      else
        @rounds[fixture.id] = Hash.new(nil)
      end
    end

    @fixtures_by_round = fixtures.group_by(&:round)
    @user = User.find_by(id: params[:user]) || current_user
  end

  def leaderboard
    fixture_time = Fixture.where(event: event).where.not(result: nil).maximum(:at)
    @fixture = Fixture.where(event: event, at: fixture_time).first
    if @fixture
      @users = League.find_by!(name: params[:league] || event).users.all

      @points = Fixture.where(event: @fixture.event, picks: {user_id: @users.map(&:id)}).where(['fixtures.at <= ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')
      @prev_points = Fixture.where(event: @fixture.event, picks: {user_id: @users.map(&:id)}).where(['fixtures.at < ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')

      @users = @users.sort_by {|u| @points.keys.index(u.id) || 0 }

    end
  end
end
