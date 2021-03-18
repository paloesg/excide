class AddDocumentRefToTopics < ActiveRecord::Migration[6.1]
  def change
    add_reference :topics, :document, foreign_key: true, type: :uuid
  end
end
