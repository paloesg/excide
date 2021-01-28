class AddTimestampsToFranchiseeTable < ActiveRecord::Migration[6.0]
  def up
    add_timestamps :franchisees, default: Time.zone.now
    change_column_default :franchisees, :created_at, nil
    change_column_default :franchisees, :updated_at, nil
  end

  def down
    remove_timestamps :franchisees
  end
end
