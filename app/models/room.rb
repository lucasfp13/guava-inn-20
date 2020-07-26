class Room < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_exception

  validates :code, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  after_find :calculate_occupancy_rates

  attr_reader :weekly_occupancy_rate, :monthly_occupancy_rate

  scope :with_capacity, ->(number_of_guests) {
    where('capacity >= ?', number_of_guests)
  }

  scope :not_available_at, ->(start_date, end_date) {
    joins(:reservations).where('start_date < ? AND end_date > ?', end_date, start_date)
  }

  private

  def occupancy_rate_calculation(next_days)
    return 0 if reservations.blank?

    ###
    # Using DateTime instead Date to work with local time zone system
    tomorrow = (DateTime.now + 1.day).to_date
    selected_period = (tomorrow..next_days.days.from_now).to_a

    days_with_reservation = 0
    reservations.each do |reservation|
      ###
      # Skipping rooms from past periods than selected period
      next if reservation.end_date < tomorrow
      ###
      # Note that on each reservation case the end_date shouldn't be considered
      # as a 'occupied day' since the end_date ends at 12:00 PM and the room is
      # free after this. So, we don't count with the last day of reservation.
      reservation_period = (reservation.start_date..(reservation.end_date - 1.day)).to_a
      ###
      # Using the bitwise AND operator to get the intersection between period
      # range and each reservation date range.
      days_with_reservation += (selected_period & reservation_period).count
    end

    ((days_with_reservation.to_f / next_days) * 100).round
  end

  def calculate_occupancy_rates
    @weekly_occupancy_rate = occupancy_rate_calculation(7)
    @monthly_occupancy_rate = occupancy_rate_calculation(30)
  end
end
