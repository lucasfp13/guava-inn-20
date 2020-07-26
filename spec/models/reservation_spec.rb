require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it 'validates presence of room' do
    reservation = build_reservation(room: nil)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:room, :blank)
  end

  it 'validates presence of start_date' do
    reservation = build_reservation(start_date: nil)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:start_date, :blank)
  end

  it 'validates presence of end_date' do
    reservation = build_reservation(end_date: nil)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:end_date, :blank)
  end

  it 'validates presence of guest_name' do
    reservation = build_reservation(guest_name: nil)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:guest_name, :blank)
  end

  it 'validates presence of number_of_guests' do
    reservation = build_reservation(number_of_guests: nil)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:number_of_guests, :blank)
  end

  it 'validates that number_of_guests should not be zero' do
    reservation = build_reservation(number_of_guests: 0)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:number_of_guests, :greater_than)
  end

  it 'validates that number_of_guests should not be negative' do
    reservation = build_reservation(number_of_guests: -1)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:number_of_guests, :greater_than)
  end

  it 'validates that number_of_guests should not be greater than ten' do
    reservation = build_reservation(number_of_guests: 15)

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(
      :number_of_guests,
      :less_than_or_equal_to
    )
  end

  it 'validates that number_of_guests should not be greater than room capacity' do
    reservation = build_reservation(
      number_of_guests: 2,
      in_room: { capacity: 1 }
    )

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(
      :number_of_guests,
      :greater_than_room_capacity
    )
  end

  it 'validates that start_date is before end_date' do
    reservation = build_reservation(
      start_date: '2020-07-23',
      end_date: '2020-07-22'
    )

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:base, :invalid_dates)
  end

  it 'validates that start_date is not equal to end_date' do
    reservation = build_reservation(
      start_date: '2020-07-23',
      end_date: '2020-07-23'
    )

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:base, :invalid_dates)
  end

  it 'validates start_date can be equal to end_date of an ongoing reservation' do
    room = build_room(
      with_reservations: [
        { start_date: '2020-07-25', end_date: '2020-07-28' }
      ]
    )

    reservation = build_reservation(
      start_date: '2020-07-28',
      end_date: '2020-07-30',
      room: room
    )

    expect(reservation).to be_valid
  end

  it 'validates end_date can be equal to start_date of an ongoing reservation' do
    room = build_room(
      with_reservations: [
        { start_date: '2020-07-25', end_date: '2020-07-28' }
      ]
    )

    reservation = build_reservation(
      start_date: '2020-07-23',
      end_date: '2020-07-25',
      room: room
    )

    expect(reservation).to be_valid
  end

  it 'validates that chosen dates are available to reservation' do
    room = build_room(
      with_reservations: [
        { start_date: '2020-07-25', end_date: '2020-07-29' }
      ]
    )

    # With both start and end dates included in reservation date range.
    reservation_1 = build_reservation(
      start_date: '2020-07-26',
      end_date: '2020-07-28',
      room: room
    )

    # With start_date included in reservation date range.
    reservation_2 = build_reservation(
      start_date: '2020-07-26',
      end_date: '2020-07-30',
      room: room
    )

    # With end_date included in reservation date range.
    reservation_3 = build_reservation(
      start_date: '2020-07-24',
      end_date: '2020-07-28',
      room: room
    )

    expect(reservation_1).to_not be_valid
    expect(reservation_1).to have_error_on(:base, :invalid_dates)

    expect(reservation_2).to_not be_valid
    expect(reservation_2).to have_error_on(:base, :invalid_dates)

    expect(reservation_3).to_not be_valid
    expect(reservation_3).to have_error_on(:base, :invalid_dates)
  end

  describe '#duration' do
    it 'returns the number of nights for the reservation' do
      reservation = build_reservation(
        start_date: '2020-08-01',
        end_date: '2020-08-05'
      )

      expect(reservation.duration).to eq(4)
    end

    context 'when start or end_date is blank' do
      it 'returns nil' do
        reservation = build_reservation(
          start_date: '2020-08-01',
          end_date: nil
        )

        expect(reservation.duration).to be_nil
      end
    end

    context 'when the start_date is equal to or after the end_date' do
      it 'returns nil' do
        reservation = build_reservation(
          start_date: '2020-08-01',
          end_date: '2020-07-31'
        )

        expect(reservation.duration).to be_nil
      end
    end
  end

  describe '#code' do
    it 'returns the room code and two-digit reservation id' do
      reservation = build_reservation(id: 2, in_room: { code: '101' })

      expect(reservation.code).to eq('101-02')
    end

    context 'when the room is not present' do
      it 'returns nil' do
        reservation = build_reservation(room: nil)

        expect(reservation.code).to be_nil
      end
    end

    context 'when the room is present but does not have code' do
      it 'returns nil' do
        reservation = build_reservation(id: 2, in_room: { code: nil })

        expect(reservation.code).to be_nil
      end
    end

    context 'when the reservation does not have id' do
      it 'returns nil' do
        reservation = build_reservation(id: nil, in_room: { code: '101' })

        expect(reservation.code).to be_nil
      end
    end

    context 'when the reservation id is greater than 99' do
      it 'returns a code with the second part having more than two digits' do
        reservation = build_reservation(id: 100, in_room: { code: '101' })

        expect(reservation.code).to eq('101-100')
      end
    end
  end
end
