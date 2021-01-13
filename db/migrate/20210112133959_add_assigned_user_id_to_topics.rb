class AddAssignedUserIdToTopics < ActiveRecord::Migration[6.0]
  def change
    add_reference :topics, :assigned_user, foreign_key: {to_table: :users}
  end
end
