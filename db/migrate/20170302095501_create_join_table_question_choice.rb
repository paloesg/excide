class CreateJoinTableQuestionChoice < ActiveRecord::Migration
  def change
    create_join_table :questions, :choices do |t|
      t.index [:question_id, :choice_id]
    end
  end
end
