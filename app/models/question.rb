class Question < ActiveRecord::Base
  belongs_to :section

  has_many :responses

  has_and_belongs_to_many :choices

  enum question_type: [:text, :number, :radio, :checkbox, :file]
end
