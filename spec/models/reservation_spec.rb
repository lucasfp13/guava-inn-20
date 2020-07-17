require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it 'validates presence of room' do
    reservation = Reservation.new

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:room, :blank)
  end

  it 'validates presence of start_date' do
    reservation = Reservation.new

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:start_date, :blank)
  end

  it 'validates presence of end_date' do
    reservation = Reservation.new

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:end_date, :blank)
  end

  it 'validates presence of guest_name' do
    reservation = Reservation.new

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:guest_name, :blank)
  end

  it 'validates presence of number_of_guests' do
    reservation = Reservation.new

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:number_of_guests, :blank)
  end

  it 'validates that number_of_guests should not be zero' do
    room = Reservation.new(number_of_guests: 0)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:number_of_guests, :greater_than)
  end

  it 'validates that number_of_guests should not be negative' do
    room = Reservation.new(number_of_guests: -1)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:number_of_guests, :greater_than)
  end

  it 'validates that number_of_guests should not be greater than ten' do
    room = Reservation.new(number_of_guests: 11)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:number_of_guests, :less_than_or_equal_to)
  end

  it 'validates that start_date is before end_date' do
    reservation = Reservation.new(start_date: '2020-08-02', end_date: '2020-08-01')

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:base, :invalid_dates)
  end

  it 'validates that start_date is not equal to end_date' do
    reservation = Reservation.new(start_date: '2020-08-01', end_date: '2020-08-01')

    expect(reservation).to_not be_valid
    expect(reservation).to have_error_on(:base, :invalid_dates)
  end

  describe '#duration' do
    it 'returns the number of nights for the reservation' do
      reservation = Reservation.new(start_date: '2020-08-01', end_date: '2020-08-05')

      expect(reservation.duration).to eq(4)
    end

    context 'when start or end_date is blank' do
      it 'returns nil' do
        reservation = Reservation.new(start_date: '2020-08-01', end_date: nil)

        expect(reservation.duration).to be_nil
      end
    end

    context 'when the start_date is equal to or after the end_date' do
      it 'returns nil' do
        reservation = Reservation.new(start_date: '2020-08-01', end_date: '2020-07-31')

        expect(reservation.duration).to be_nil
      end
    end
  end

  describe '#code' do
    it 'returns the room code and two-digit reservation id' do
      room = Room.new(code: '101')
      reservation = Reservation.new(id: 2, room: room)

      expect(reservation.code).to eq('101-02')
    end

    context 'when the room is not present' do
      it 'returns nil' do
        reservation = Reservation.new(room: nil)

        expect(reservation.code).to be_nil
      end
    end

    context 'when the room is present but does not have code' do
      it 'returns nil' do
        room = Room.new(code: nil)
        reservation = Reservation.new(id: 2, room: room)

        expect(reservation.code).to be_nil
      end
    end

    context 'when the reservation does not have id' do
      it 'returns nil' do
        room = Room.new(code: '101')
        reservation = Reservation.new(id: nil, room: room)

        expect(reservation.code).to be_nil
      end
    end

    context 'when the reservation id is greater than 99' do
      it 'returns a code with the second part having more than two digits' do
        room = Room.new(code: '101')
        reservation = Reservation.new(id: 100, room: room)

        expect(reservation.code).to eq('101-100')
      end
    end
  end
end
