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
    "bg-#{color}-500/10 hover:bg-#{color}-500/20 border border-#{color}-500/30 text-#{color}-300 hover:text-#{color}-200"
  end

  def badge_classes
    "bg-#{color}-500/10 text-#{color}-300 border-#{color}-500/30"
  end

  def dot_classes
    "bg-#{color}-500"
  end

  def accent_text_classes
    "text-#{color}-400"
  end

  private

  def assign_default_position
    return if position.present?

    self.position = (self.class.maximum(:position) || -1) + 1
  end
end
