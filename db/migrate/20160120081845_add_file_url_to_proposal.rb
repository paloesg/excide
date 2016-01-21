class AddFileUrlToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :file_url, :string
  end
end
