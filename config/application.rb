require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReactivePlanning
  class Application < Rails::Application
    config.react.addons = true
    config.browserify_rails.commandline_options = "-t coffee-reactify --extension=\".js.cjsx\""
  end
end
