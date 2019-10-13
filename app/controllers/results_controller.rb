class ResultsController < ApplicationController
  before_action :authenticate_user!
  # skip_before_action :authenticate_user!, if: :current_admin
  before_action :allow_setting, except: [:index, :leaderboard]

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
      league = League.find_by(name: params[:league])
      @users = league ? league.users.all : Pick.includes(:fixture, :user).where.not(pick: 0).where(fixtures: { event: event }).map(&:user).uniq

      @points = Fixture.where(event: @fixture.event, picks: {user_id: @users.map(&:id)}).where(['fixtures.at <= ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')
      @prev_points = Fixture.where(event: @fixture.event, picks: {user_id: @users.map(&:id)}).where(['fixtures.at < ?', @fixture.at]).includes(:picks).group(:user_id).order('sum(picks.score)').sum('picks.score')

      @users = @users.sort_by {|u| @points.keys.index(u.id) || 10000 }
      @users.unshift(current_user) if @users.index(current_user) > 5
    end
  end

  def new
    @fixture = next_fixture_to_update.first
  end

  def update
    @fixture = next_fixture_to_update.first
    if params[:id].to_i != @fixture.id
      flash[:notice] = 'Result of that fixture can not be set at this time'
      render :new
    else
      @fixture.update_result(params[:result].to_i)
      redirect_to new_result_path
    end
  end

  def cancel
    @fixture = next_fixture_to_update.first
    if params[:id].to_i != @fixture.id
      flash[:notice] = 'Result of that fixture can not be set at this time'
      render :new
    else
      @fixture.cancel!
      redirect_to new_result_path
    end
  end

  private

  def next_fixture_to_update
    # TODO: avoid hardcoding the event...
    Fixture.where('at < ?', Time.now).where(result: nil, event: '2019').order(:at)
  end

  def allow_setting
    redirect_to root_path unless current_user.result_setter?
  end
end
