class Transaction < ApplicationRecord
  enum :status, { pending: 0, processed: 1, staging: 2 }, default: :pending
  enum :transaction_type, { expense: 0, income: 1, transfer: 2 }, default: :expense

  belongs_to :envelope, optional: true
  belongs_to :ivy_category, optional: true

  validates :date, :amount, :description, presence: true
  validates :envelope, presence: true, if: :processed?
  validates :receiver, presence: true, if: :transfer?

  def self.next_pending
    pending.order(:date, :id).first
  end

  # En Ivy Wallet todos los montos se exportan positivos.
  # El tipo (expense/income/transfer) ya indica el sentido del movimiento.
  def csv_amount
    amount.abs
  end

  def csv_title
    title.presence || description
  end
end
