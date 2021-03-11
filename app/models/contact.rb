class Contact < ApplicationRecord
  belongs_to :company
  # Duplicate contacts when adding to fundraising board. Cloned_by describes the company that clones the contact
  belongs_to :cloned_by, class_name: 'Company'
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_rich_text :investor_information

  has_one_attached :investor_company_logo

  has_many :notes, as: :notable, dependent: :destroy

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
