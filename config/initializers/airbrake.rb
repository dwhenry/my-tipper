require 'rake'
require 'airbrake/rake'

Airbrake.configure do |config|
  config.project_id = '115806'
  config.project_key = '88bbc6aa8baed00192c1e0a4f6773061'
  # config.rescue_rake_exceptions = true
end
