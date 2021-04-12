class AddSettingsToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :settings, :json, default: [{franchisee_list: 'true', outlet_list: 'true', onboarding_management: 'true', site_audit_management: 'true', royalty_collection_management: 'true', financial_performance: 'true', communication_hub: 'true', announcement: 'false', leads_management: 'false' }]
  end
end
