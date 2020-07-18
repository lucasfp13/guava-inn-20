class Room < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_exception

  validates :code, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  scope :with_capacity, ->(number_of_guests) {
    where('capacity >= ?', number_of_guests)
  }

  scope :not_available_at, ->(start_date, end_date) {
    joins(:reservations).where('start_date < ? AND end_date > ?', end_date, start_date)
  }
end
