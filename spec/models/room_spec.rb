require 'rails_helper'

RSpec.describe Room, type: :model do
  it 'validates presence of code' do
    room = build_room(code: nil)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :blank)
  end

  it 'validates uniqueness of code' do
    create_room(code: '101', capacity: 2)

    room = build_room(code: '101')
    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :taken)
  end

  it 'validates minimum length of code' do
    room = build_room(code: '10')

    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :too_short)
  end

  it 'validates maximum length of code' do
    room = build_room(code: '1000000000')

    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :too_long)
  end

  it 'validates presence of capacity' do
    room = build_room(capacity: nil)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :blank)
  end

  it 'validates that capacity should not be zero' do
    room = build_room(capacity: 0)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :greater_than)
  end

  it 'validates that capacity should not be negative' do
    room = build_room(capacity: -1)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :greater_than)
  end

  it 'validates that capacity should not be greater than ten' do
    room = build_room(capacity: 11)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :less_than_or_equal_to)
  end

  it 'validates that, when editing, capacity should not be less than existing reservations guests number.' do
    room = create_room(capacity: 2, with_reservations: [{ number_of_guests: 2}])
    room.capacity = 1

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :invalid_capacity)
  end

  describe 'weekly, monthly and occupancy rates' do
    context 'when none reservations exists' do
      it 'occupancy rate is zero' do
        room = create_room

        expect(room.occupancy_rate_calculation(7)).to equal(0)
        expect(room.occupancy_rate_calculation(30)).to equal(0)
      end
    end

    context 'when in the next 7 days there are reservations' do
      it 'validates that weekly occupancy rate is 100%' do
        tomorrow = (Time.now + 1.day).to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 8.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(7)).to equal(100)
      end

      it 'validates that monthly occupancy rate is 23%' do
        tomorrow = Time.now.to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 8.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(30)).to equal(23)
      end
    end

    context 'when in the next 4 days there are reservations' do
      it 'validates that weekly occupancy rate is 57%' do
        tomorrow = Time.now.to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 5.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(7)).to equal(57)
      end

      it 'validates that monthly occupancy rate is 13%' do
        tomorrow = Time.now.to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 5.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(30)).to equal(13)
      end
    end

    context 'when in the next 27 days there are reservations' do
      it 'validates that weekly occupancy rate is 100%' do
        tomorrow = Time.now.to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 28.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(7)).to equal(100)
      end

      it 'validates that monthly occupancy rate is 90%' do
        tomorrow = Time.now.to_date
        room = create_room(
          with_reservations: [{ start_date: tomorrow, end_date: 28.days.from_now }]
        )

        expect(room.occupancy_rate_calculation(30)).to equal(90)
      end
    end
  end
end
