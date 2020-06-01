require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "active_storage/engine"
require "action_text/engine"



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Excide
  class Application < Rails::Application
    config.middleware.use Rack::Attack

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Singapore'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sucker_punch

    # Zeitwerk returns NameError if we use it. Uncomment config.load_defaults to use Zeitwerk next time if there's a solution
    # config.load_defaults "6.0"
    config.autoload = :classic
    # The default configuration for Rails 6
    # Zeitwerk is able to load classes and modules on demand (autoloading), or upfront (eager loading).

    # Set the default require belongs_to relations to optional
    config.active_record.belongs_to_required_by_default = false
  end
end
