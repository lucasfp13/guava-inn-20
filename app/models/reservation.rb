class Reservation < ApplicationRecord
  belongs_to :room

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :guest_name, presence: true
  validates :number_of_guests, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validate :start_date_is_before_end_date

  def duration
    if start_date.present? && end_date.present? && end_date > start_date
      (end_date - start_date).to_i
    end
  end

  def code
    if id.present? && room&.code.present?
      formatted_id = '%02d' % id
      "#{room.code}-#{formatted_id}"
    end
  end

  private

  def start_date_is_before_end_date
    if start_date.present? && end_date.present? && start_date >= end_date
      errors.add(:base, :invalid_dates, message: 'The start date should be before the end date')
    end
  end
end
