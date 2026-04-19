class Transaction < ApplicationRecord
  enum :status, { pending: 0, processed: 1 }, default: :pending

  belongs_to :envelope, optional: true

  validates :date, :amount, :description, presence: true
  validates :envelope, presence: true, if: :processed?

  def self.next_pending
    pending.order(:date, :id).first
  end
end
