class AddSettingsToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :settings, :json, default: [{search_feature: 'true', kanban_board: 'true', dataroom: 'true', our_investor_or_startup: 'true', cap_table: 'true', performance_report: 'true', shared_file: 'true', resource_portal: 'true' }]
  end
end
