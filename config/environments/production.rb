Rails.application.configure do
  # Prepare the ingress controller used to receive mail
  # config.action_mailbox.ingress = :relay

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Disable logging requests for static assets.
  config.assets.quiet = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use lograge gem
  config.lograge.enabled = true

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :amazon

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # TOP_LEVEL_DOMAIN is the ending of the url. Eg, '.com', '.herokuapp.com' etc
  # This is so that Heroku review apps will get the assets properly
  # ENV['HOSTNAME'] will identify the 'www' for production. For review apps and staging, we can keep it empty first
  if ENV['HEROKU_APP_NAME'] == 'excide'
    config.action_controller.asset_host = "https://app.paloe.com.sg"
  elsif ENV['HEROKU_APP_NAME'] == 'asiawide'
    config.action_controller.asset_host = "https://app.asiawidedigital.com"
  else
    config.action_controller.asset_host = "https://" + ENV['HEROKU_APP_NAME'] + ".herokuapp.com"
  end

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Action Mailer configuration, using Sendgrid API to send email (using sendgrid's dynamic template email)
  config.action_mailer.delivery_method = :sendgrid_actionmailer
  config.action_mailer.sendgrid_actionmailer_settings = {
    api_key: ENV['SENDGRID_API_KEY'],
    raise_delivery_errors: true
  }

  config.action_mailbox.ingress = :sendgrid

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
