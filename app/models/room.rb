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

  def occupancy_rate_calculation(period)
    return 0 if reservations.blank?

    ###
    # using DateTime to work with local time zone system, but needs to convert
    # back to the Date format to match with Reservation model 'date' field type
    tomorrow = (DateTime.now + 1).to_date
    period_range = (tomorrow..(tomorrow + period)).to_a

    days_with_reservation = 0
    reservations.each do |reservation|
      reservation_range = (reservation.start_date..reservation.end_date).to_a
      ###
      # using the bitwise AND operator to get the intersection between
      # period range and each reservation date range and counting them
      days_with_reservation += (period_range & reservation_range).count
    end

    ((days_with_reservation.to_f / period) * 100).round
  end

  def calculate_occupancy_rates
    @weekly_occupancy_rate = occupancy_rate_calculation(7)
    @monthly_occupancy_rate = occupancy_rate_calculation(30)
  end
end
