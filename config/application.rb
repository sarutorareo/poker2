require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Poker2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.test_framework = "rspec"
    end
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # サービスをオートロードする
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/services/dealer)
    config.autoload_paths += %W(#{config.root}/app/forms)
    config.autoload_paths += %W(#{config.root}/app/forms/dealer)
  end
end
