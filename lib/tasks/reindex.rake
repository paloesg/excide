namespace :reindex do
  desc "Reindex workflows on Algolia"
  task workflows: :environment do
    Workflow.reindex
  end
end
