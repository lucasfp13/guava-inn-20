# Rooms

room_101 = Room.create!(
  code: '101',
  capacity: 2,
)

room_102 = Room.create!(
  code: '102',
  capacity: 4,
)

room_103 = Room.create!(
  code: '103',
  capacity: 5,
)

room_201 = Room.create!(
  code: '201',
  capacity: 4,
)

room_202 = Room.create!(
  code: '202',
  capacity: 6,
)

room_203 = Room.create!(
  code: '203',
  capacity: 2,
)

# Reservations

Reservation.create!(
  room: room_101,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_101.capacity),
  start_date: '2020-07-28',
  end_date: '2020-07-29',
)

Reservation.create!(
  room: room_101,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_101.capacity),
  start_date: '2020-07-29',
  end_date: '2020-08-02',
)

Reservation.create!(
  room: room_102,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_102.capacity),
  start_date: '2020-07-28',
  end_date: '2020-07-31',
)

Reservation.create!(
  room: room_102,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_102.capacity),
  start_date: '2020-07-31',
  end_date: '2020-08-04',
)

Reservation.create!(
  room: room_102,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_102.capacity),
  start_date: '2020-08-04',
  end_date: '2020-08-10',
)

Reservation.create!(
  room: room_203,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_203.capacity),
  start_date: '2020-07-25',
  end_date: '2020-07-30',
)

Reservation.create!(
  room: room_203,
  guest_name: Faker::Name.unique.name,
  number_of_guests: rand(1..room_203.capacity),
  start_date: '2020-08-02',
  end_date: '2020-08-10',
)
