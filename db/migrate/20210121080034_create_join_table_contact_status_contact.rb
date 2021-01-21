class CreateJoinTableContactStatusContact < ActiveRecord::Migration[6.0]
  def change
    create_join_table :contact_statuses, :contacts do |t|
      t.index [:contact_status_id, :contact_id], name: 'contact_statuses_and_contacts_index'
    end
  end
end
