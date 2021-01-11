class Topic < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :company
  belongs_to :startup, class_name: "Company"

  has_many :notes, as: :notable, dependent: :destroy

  enum question_category: { state_interest: 0, due_dilligence: 1, investor_management: 2}
  enum status: { need_answer: 0, need_approval: 1, answered: 2, closed: 3}

  accepts_nested_attributes_for :notes, reject_if: :all_blank, allow_destroy: true

  aasm column: :status, enum: true do
    state :need_answer, initial: true
    # Assign startup users to answer investor's question
    event :assign_user do
      transitions from: :need_answer, to: :need_approval
    end
    # Startup admin rejects user's answer to investor's question
    event :rejected do
      transitions from: :need_approval, to: :need_answer
    end
    # Startup admin approves user's answer to investor's question
    event :approved do
      transitions from: :need_approval, to: :answered
    end
    # Investor can close the question at any time
    event :close_question do
      transitions from: [:need_answer, :need_approval, :answered], to: :closed
    end
  end
end
