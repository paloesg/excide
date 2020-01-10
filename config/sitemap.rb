# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.excide.co"

# Pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'

# Store on S3 using Fog
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new

# Inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"

# Pick a namespace within your bucket to organize your maps
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  add about_path
  add vfo_path
  add financial_analytics_reporting_path
  add business_plan_assistance_path
  add corporate_planning_path
  add forecasting_sensitivity_analysis_path
  add bugeting_forecasting_path
  add ipo_support_path
  add mergers_acquisitions_support_path
  add exit_strategy_path
  add turnaround_management_path
  add fund_raising_path
  add symphony_xero_automation_path
end
