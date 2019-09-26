class TeamWrappersController < ApplicationController

  def index
    wrappers = TeamWrapper.where.not(name: nil)
    wrappers = wrappers.for_event(event).order("fixtures.at")
    @wrappers_by_round = wrappers.group_by {|w| w.fixture.round }
  end

  def create
    params[:wrappers].each do |wrapper, value|
      next if value.blank?

      wrapper_id = wrapper.split('_').last.to_i
      tw = TeamWrapper.find(wrapper_id)
      tw.update_attribute(:team_id, value.to_i)
    end
    redirect_to team_wrappers_path(paramify)
  end
end
