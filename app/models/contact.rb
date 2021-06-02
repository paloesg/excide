class Contact < ApplicationRecord
  belongs_to :company
  # Duplicate contacts when adding to fundraising board. Cloned_by describes the company that clones the contact
  belongs_to :cloned_by, class_name: 'Company'
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_rich_text :investor_information

  has_one_attached :investor_company_logo

  has_many :notes, as: :notable, dependent: :destroy
  
  validates :company_id, uniqueness: { scope: :cloned_by_id}

  include AlgoliaSearch
  algoliasearch do
    attribute :company_name, :email, :phone, :searchable
    attribute :company do
      { name: company&.name, slug: company&.slug }
    end
    attribute :filename do
      "#{ investor_company_logo.present? ? investor_company_logo&.filename : '' }"
    end
    attribute :image_src do
      "#{ investor_company_logo.present? ? "rails/active_storage/blobs/#{investor_company_logo.signed_id}/#{investor_company_logo.filename}" : "packs/media/src/images/motif/avatar-no-photo-692431e773d7106db54841efda3efd80.svg" }"
    end
  end

  def clone_contact
    self.deep_clone include: [:rich_text_investor_information] do |original, kopy|
      if kopy.is_a?(Contact) && original.investor_company_logo.attached?
        original.investor_company_logo.open do |tempfile|
          kopy.investor_company_logo.attach({
            io: File.open(tempfile.path),
            filename: original.investor_company_logo.blob.filename,
            content_type: original.investor_company_logo.blob.content_type
          })
        end
      end
    end
  end
end
