class AddSummaryToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :summary, :string
    add_column :profiles, :featured, :string
  end
end
