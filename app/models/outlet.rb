class Outlet < ApplicationRecord
  belongs_to :company
  belongs_to :franchisee

  has_one :address, as: :addressable, dependent: :destroy

  has_many :documents, dependent: :destroy
  has_many :outlets_users
  has_many :users, through: :outlets_users, dependent: :destroy
  has_many :workflows, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  has_one_attached :header_image
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :franchisee, :reject_if => :all_blank, :allow_destroy => true

  include AlgoliaSearch
  include Rails.application.routes.url_helpers
  algoliasearch do
    attribute :name
    attribute :header_image_src do
      "#{ header_image.present? ? "/rails/active_storage/blobs/redirect/#{header_image.signed_id}/#{header_image.filename}?disposition=attachment" : "/packs/media/src/images/motif/franchisee-outlets-empty-state-2ccd2171b204978b7274a7fb9084461d.png" }"
    end
    attribute :url do
      edit_motif_outlet_path(self.id)
    end
    attribute :franchisee_licensee do
      "#{ franchisee&.franchise_licensee.present? ? franchisee&.franchise_licensee : company.name }"
    end
    attribute :country do
      "#{ country.present? ? country : "No country"}"
    end
    attribute :label do
      # Check if outlet is direct-owned or franchised
      "#{ franchisee_id.present? ? "Franchised" : "Direct Owned"}"
    end
  end

  def clone_templates_for_outlet
    # Get the company level's template (in case there are any updates to these templates)
    motif_onboarding_template = Template.find_by(title: "[SAMPLE] Onboarding Template - #{self.company.name}")
    motif_site_audit_template = Template.find_by(title: "[SAMPLE] Site Audit Template - #{self.company.name}")
    motif_royalty_collection_template = Template.find_by(title: "[SAMPLE] Royalty Collection Template - #{self.company.name}")
    # Check if the templates are all present. If not, don't clone
    if [motif_onboarding_template, motif_site_audit_template, motif_royalty_collection_template].all?(&:present?)
      [motif_onboarding_template, motif_site_audit_template, motif_royalty_collection_template].each do |template|
        cloned_template = template.deep_clone include: { sections: :tasks }
        cloned_template.title = "#{template.template_type.titleize} - #{self.name}"
        # cloned template should belongs to parent company unless it is a franchisor (then we use self.company)
        cloned_template.company = self.company.parent.present? ? self.company.parent : self.company
        # The code below does not clone folders at the moment because it will find the parent company's folder.
        cloned_template.tasks.each { |task| task.clone_folder(cloned_template.company) }
        cloned_template.save
      end
    end
  end

  # For ADA user limit progress
  def user_limit_progress
    (self.users.length / self.user_limit.to_f) * 100
  end
  # Set color of progress bar, red when user hits the limit
  def user_limit_progress_bar_color
    case self.user_limit.to_f - self.users.length
    when 0
      "bg-motif-red"
    else
      return
    end
  end
end
