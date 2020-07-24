class Reservation < ApplicationRecord
  belongs_to :room

  before_destroy :check_if_it_is_a_ongoing_reservation, prepend: true

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :guest_name, presence: true
  validates :number_of_guests, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  validate :start_date_is_before_end_date, if: -> { start_date.present? &&
                                                    end_date.present? }
  validate :number_of_guests_is_not_greater_than_capacity, if: -> { number_of_guests.present? }
  validate :chosen_date_is_available_for_reservation, if: -> { start_date.present? &&
                                                               end_date.present? &&
                                                               room_id.present? }

  def duration
    return if start_date.blank? || end_date.blank? || start_date > end_date

    (end_date - start_date).to_i
  end

  def code
    return if id.blank? || room&.code.blank?

    formatted_id = '%02d' % id
    "#{room.code}-#{formatted_id}"
  end

  private

  def check_if_it_is_a_ongoing_reservation
    return if end_date < Time.now.to_date
    return if end_date == Time.now.to_date && Time.now.hour >= 12

    throw(:abort)
  end

  def start_date_is_before_end_date
    return if start_date < end_date

    errors.add(:base, :invalid_dates, message: 'The start date should be before the end date')
  end

  def number_of_guests_is_not_greater_than_capacity
    return if room.blank? || room.capacity >= number_of_guests

    errors.add(:base, :insufficient_capacity, message: "The number of guests shouldn't be greater than room capacity")
  end

  def chosen_date_is_available_for_reservation
    return if room.blank?
    return if Reservation.where('room_id = ? AND start_date < ? AND end_date > ?', room_id, end_date, start_date).empty?

    errors.add(:base, :unavailable_for_reservation, message: "The room isn't available in the chosen date")
  end
end
