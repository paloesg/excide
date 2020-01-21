# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( parallax.js application-dashboard.css )

#foundation_emails in the vendor folder can be individually precompile so that we can reference to it
Rails.application.config.assets.precompile += %w( foundation_emails.css )

Rails.application.config.assets.precompile += %w( metronic/application-footer.js )
Rails.application.config.assets.precompile += %w( stack/footer.js )
