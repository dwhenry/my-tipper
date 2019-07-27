module LoggedInAs
  def logged_in_as(user)
    login_as(user, :scope => :user, :run_callbacks => false)
    yield
    logout(:user)
  end
end

RSpec.configuration.include(LoggedInAs)
