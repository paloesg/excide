class AddDedocoVisualBuilderLinkToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :dedoco_visual_builder_link, :string
  end
end
