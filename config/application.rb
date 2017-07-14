require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Excide
  class Application < Rails::Application
    # Reverse proxy to point subdirectory to a different server.
    config.middleware.insert(0, Rack::ReverseProxy) do
      reverse_proxy_options preserve_host: true
      reverse_proxy '/blog', 'http://ec2-54-169-106-168.ap-southeast-1.compute.amazonaws.com/'
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Override rails behaviour of wrapping form fields with error with a field_with_errors div to prevent issues with materialize
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }
  end
end
