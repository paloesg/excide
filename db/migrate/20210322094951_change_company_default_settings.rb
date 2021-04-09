class ChangeCompanyDefaultSettings < ActiveRecord::Migration[6.1]
  def change
    change_column_default :companies, :settings, from: [{search_feature: 'true', kanban_board: 'true', dataroom: 'true', our_investor_or_startup: 'true', cap_table: 'true', performance_report: 'true', shared_file: 'true', resource_portal: 'true' }], to: [{search_feature: 'true', kanban_board: 'true', dataroom: 'true', our_investor_or_startup: 'true', cap_table: 'true', performance_report: 'true', shared_file: 'true', resource_portal: 'true', announcement: 'true' }]
  end
end
