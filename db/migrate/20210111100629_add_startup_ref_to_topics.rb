class AddStartupRefToTopics < ActiveRecord::Migration[6.0]
  def change
    add_reference :topics, :startup, type: :uuid, foreign_key: {to_table: :companies}
  end
end
