class AddStatusToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :status, :integer
  end
end
