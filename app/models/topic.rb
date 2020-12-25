class Topic < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum status: { need_answer: 0, need_approval: 1, answered: 2, closed: 3}
  enum question_category: { state_interest: 0, due_dilligence: 1, investor_management: 2}
end
