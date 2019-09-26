class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :redirect_for_staging

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :event, :paramify, :league

  protected

  def redirect_for_staging
    if request.host =~ /staging/
      redirect_to 'https://my-tipper.herokuapp.com'
    end
  end

  def paramify(vals={})
    { event: event, league: league }.merge(vals)
  end

  def current_user(over_ride: true)
    super() #|| (over_ride && over_ride_user)
  end

  def event
    # this should not really be hard coded.. but makes it a little easier during the initial implementation
    params[:event].presence || '2019'
    '2019' # force the 2019 event to solve cookie issue for dad...
  end

  def league
    return unless params[:league].present?
    return if params[:league].is_a?(ActionController::UnfilteredParameters)
    params[:league]
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
