class Transaction < ApplicationRecord
  enum :status, { pending: 0, processed: 1 }, default: :pending

  belongs_to :pocket, optional: true

  validates :date, :amount, :description, presence: true
  validates :pocket, presence: true, if: :processed?

  def self.next_pending
    pending.order(:date, :id).first
  end
end
