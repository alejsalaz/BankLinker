class Category < ApplicationRecord
  has_many :transactions, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :position, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :name) }

  before_validation :assign_position, on: :create

  private

  def assign_position
    self.position ||= (self.class.maximum(:position) || 0) + 1
  end
end
