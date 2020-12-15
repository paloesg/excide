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

  after_create :clone_templates_for_outlet

  def clone_templates_for_outlet
    # Get the company level's template (in case there are any updates to these templates)
    motif_onboarding_template = Template.find_by(title: "Onboarding - #{self.company.name}")
    motif_site_audit_template = Template.find_by(title: "Site Audit - #{self.company.name}")
    motif_royalty_collection_template = Template.find_by(title: "Royalty Collection - #{self.company.name}")
    # Check if the templates are all present. If not, don't clone
    if [motif_onboarding_template, motif_site_audit_template, motif_royalty_collection_template].all?(&:present?)
      [motif_onboarding_template, motif_site_audit_template, motif_royalty_collection_template].each do |template|
        cloned_template = template.deep_clone include: { sections: :tasks }
        cloned_template.title = "#{template.template_type.titleize} - #{self.name}"
        cloned_template.company = self.company
        cloned_template.save
      end
    end
  end
end
