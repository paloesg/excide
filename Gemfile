source 'https://rubygems.org'

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'slim-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Fix issues with jquery caused by turbolinks
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10.0'
# Use puma web server
gem 'puma'
# Set timeout for long running processes
gem 'rack-timeout'
# Better Rails logging
gem 'lograge'
# The default JavaScript compiler for Rails 6
gem 'webpacker', '~> 5.2.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

#################################################
#                                               #
# Login, authentication, roles, access-control, #
# and security                                  #
#                                               #
#################################################

# Authentication
gem 'devise'
# Stripe
gem 'stripe'
gem 'stripe_event'
# Roles
gem 'rolify'
# Authorization
gem 'pundit'
# LinkedIn API integration
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-oauth2'
# Xero API integration for partner app
gem 'xeroizer', git: 'https://github.com/waynerobinson/xeroizer.git'

# Protect app from bad clients
gem 'rack-attack'

#################################################
#                                               #
#             App specific functions            #
#                                               #
#################################################

# State machine gem
gem 'aasm'
# Docusign gem for e-signature
gem 'docusign_rest'
# SMS integration with Twilio
gem 'twilio-ruby'
# Manage ordering for survey objects
gem 'acts_as_list'
# For tagging
gem 'acts-as-taggable-on', '~> 6.5.0'
# Use user friendly slugs
gem 'friendly_id', '~> 5.4.0'
# Amazon S3 SDK
gem 'aws-sdk-s3', '~> 1.80.0'
gem 'aws-sdk-textract', '~> 1.18.0'
# Sitemap generator
gem 'sitemap_generator'
# Uploading of sitemap to AWS
gem 'fog-aws'
# Set meta tags
gem 'meta-tags'
# Activity feed
gem 'public_activity'
# Handle money
gem 'money-rails', '~>1.13.0'
# Ruby asynchronous processing
gem 'sucker_punch', '~> 2.1.0'

gem 'popper_js'
# Themify icon set web fonts
gem 'themify-icons-rails', git: 'https://github.com/scratch-soft/themify-icons-rails.git'
# Font Awesome Rails
gem 'font_awesome5_rails'
# Use inky for email templating
gem 'inky-rb', require: 'inky'
# Stylesheet inlining for email
gem 'premailer-rails'
# Default processer: MiniMagick. Enable variant for image using ActiveStorage
gem 'image_processing', '~> 1.11.0'

# Nested form helper
# gem "cocoon"
# cocoon have a problem, so need use git first, solved in https://stackoverflow.com/questions/13190683/no-new-object-passed-to-cocoon-callback
gem 'cocoon'
# WYSIWYG editor
gem 'trix'
# Render calendar
gem 'simple_calendar', '~> 2.4.0'
# Algolia search
gem 'algoliasearch-rails'
# Selectize autocomplete selection
gem 'selectize-rails'
# Get mime type from filename
gem 'mini_mime'
# Shorten UUID to make it more user friendly
gem 'shortuuid'

# Calculate business days
gem 'business_time'
# Used for area code
gem 'countries', require: 'countries/global'
# CHecks phone number validity
gem 'phonelib'
# In-app notification feature
gem 'activity_notification'
# Integrate Slack API
gem 'slack-ruby-client'

gem 'ancestry'

# Backend admin
gem 'administrate', '0.14.0'
gem 'administrate-field-image'
gem 'administrate-field-nested_has_many'
gem 'administrate-field-jsonb'
gem 'administrate-field-active_storage'

# Deep cloning for cloning of template with associated sections
gem 'deep_cloneable', '~> 3.0.0'

# Heroku requirement for static asset serving and logging
gem 'rails_12factor', group: :production

# Analytics
gem 'mixpanel-ruby'

# Error monitoring
gem 'rollbar'
gem 'oj'
gem 'snitcher'

# Performance reporting
gem 'skylight'
gem 'scout_apm'

group :development do
  gem 'rails_real_favicon'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'pry-rails'
  gem 'bullet'
  gem 'derailed_benchmarks'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug'
  # Run pry remotely
  gem 'pry-remote'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Better error page in development
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'rails-erd'
  gem 'rack-mini-profiler'

  # Add squasher to collate old migration file
  gem 'squasher', '>= 0.6.2'
  gem 'foreman'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Manage env variables during development and testing
  gem 'dotenv-rails'

  # Testing framework
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'shoulda'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'

  gem 'webmock'

  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker', git: 'https://github.com/stympy/faker.git'
end
