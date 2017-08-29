source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem "slim-rails"
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '< 5'
# Fix issues with jquery caused by turbolinks
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Force sprockets rails to use version 2.3.3 to fix Heroku deployment issue
gem 'sprockets-rails', '2.3.3'
# Use puma web server
gem 'puma'
# Set timeout for long running processes
gem 'rack-timeout'
# Reverse proxy to proxy blog server to primary domain
gem "rack-reverse-proxy", require: "rack/reverse_proxy"

################################################
#                                              #
# Login, authentication, roles, access-control #
#                                              #
################################################

# Authentication
gem 'devise'
# Roles
gem 'rolify'
# Authorization
gem 'pundit'
# LinkedIn API integration
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.3.1'
gem 'omniauth-linkedin-oauth2'

################################################
#                                              #
#             App specific functions           #
#                                              #
################################################

# State machine gem
gem 'aasm'
# Payments integration with Stripe
gem 'stripe'
# Docusign gem for e-signature
gem 'docusign_rest'
# SMS integration with Twilio
gem 'twilio-ruby'
# Manage ordering for survey objects
gem 'acts_as_list'
# Use user friendly slugs
gem 'friendly_id', '~> 5.1.0'
# Amazon S3 SDK
gem 'aws-sdk', '~> 2'
# Sitemap generator
gem 'sitemap_generator'
# Uploading of sitemap to AWS
gem 'fog-aws'
# Set meta tags
gem 'meta-tags'
# Activity feed
gem 'public_activity'

# Analytics
gem 'mixpanel-ruby'

# Error monitoring
gem 'rollbar'
gem 'oj', '~> 2.12.14'
gem 'snitcher'

# Frontend framework
gem 'bootstrap-sass'
# Themify icon set web fonts
gem 'themify-icons-rails'
# Nested form helper
gem "cocoon"
# WYSIWYG editor
gem 'trix'
# Date time picker
gem "datetime_picker_rails"

#Backend admin
gem 'administrate'
gem 'administrate-field-image'
gem 'administrate-field-nested_has_many', github: 'ContainerMb4/administrate-field-nested_has_many'

# Heroku requirement for static asset serving and logging
gem 'rails_12factor', group: :production

group :development do
  gem 'rails_real_favicon'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Manage env variables during development and testing
  gem 'dotenv-rails'

  # Better error page in development
  gem "better_errors"
  gem "binding_of_caller"
end

