class Pocket < ApplicationRecord
  AVAILABLE_COLORS = %w[
    slate gray zinc red orange amber yellow lime green
    emerald teal cyan sky blue indigo violet purple
    fuchsia pink rose
  ].freeze

  has_many :transactions, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :color, presence: true, inclusion: { in: AVAILABLE_COLORS }
  validates :position, presence: true, numericality: { only_integer: true }

  before_validation :assign_default_position, on: :create

  scope :ordered, -> { order(:position, :id) }

  def button_classes
    "bg-#{color}-600 hover:bg-#{color}-700"
  end

  def badge_classes
    "bg-#{color}-100 text-#{color}-800 border-#{color}-200"
  end

  private

  def assign_default_position
    return if position.present?

    self.position = (self.class.maximum(:position) || -1) + 1
  end
end
