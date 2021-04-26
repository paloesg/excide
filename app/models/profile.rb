class Profile < ApplicationRecord
  belongs_to :company

  has_rich_text :company_information

  has_one_attached :profile_logo
  acts_as_taggable_on :categories

  include AlgoliaSearch
  algoliasearch do
    attribute :name
    attribute :company do
      { name: company&.name, slug: company&.slug }
    end
    attribute :filename do
      "#{ profile_logo.present? ? profile_logo&.filename : '' }"
    end
    attribute :image_src do
      "#{ profile_logo.present? ? "rails/active_storage/blobs/#{profile_logo.signed_id}/#{profile_logo.filename}" : "packs/media/src/images/motif/avatar-no-photo-692431e773d7106db54841efda3efd80.svg" }"
    end
  end
end
