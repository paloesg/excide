class AddStripeCustomerIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_card_token, :string
  end
end
