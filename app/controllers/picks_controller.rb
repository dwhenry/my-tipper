class PicksController < ApplicationController
  before_action :authenticate_user! #, except: :current_admin
  # skip_before_action :authenticate_user!, if: :current_admin

  def index
    fixtures = Fixture.includes({home: :team}, {away: :team}).order(:at)
    fixtures = fixtures.where(event: event)

    @upcoming_fixtures = fixtures.where(['at > ?', Time.now.utc])
    @past_fixtures = fixtures.where(['at <= ?', Time.now.utc])

    @pick = Pick.where(user_id: current_user.id).group(:fixture_id).maximum(:pick) # returns hash of {fixture_id => pick_value}
  end

  def create
    params[:picks].each do |fixture, value|
      next if value.blank?

      fixture_id = fixture.split('_').last.to_i
      pick = Pick.find_or_initialize_by(fixture_id: fixture_id, user_id: current_user.id)
      pick.update_attributes(pick: value.to_i)
    end

    respond_to do |format|
      format.html { redirect_to picks_path(paramify) }
      format.json { { status: 'success' } }
    end
  end
end
