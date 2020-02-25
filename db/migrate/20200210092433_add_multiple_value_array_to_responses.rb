class AddMultipleValueArrayToResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :responses, :multiple_choices_array, :string
  end
end
