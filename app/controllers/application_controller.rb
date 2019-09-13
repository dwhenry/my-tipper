class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :redirect_for_staging

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :only_one_login
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
    super() || (over_ride && over_ride_user)
  end

  def over_ride_user
    if current_admin
      session[:email] = nil if params[:clear_e]

      email = params[:e] || session[:email]
      session[:email] = email
      User.find_by(email: email)
    end
  end

  def event
    # this should not really be hard coded.. but makes it a little easier during the initial implementation
    params[:event].presence || '2019'
  end

  def league
    return unless params[:league].present?
    return if params[:league].is_a?(ActionController::UnfilteredParameters)
    params[:league]
  end

  def only_one_login
    if current_user(over_ride: false) && current_admin
      sign_out_all_scopes
      flash[:alert] = "You can only be logged in as a sign user type are any one time"
      redirect_to root_path(paramify)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
