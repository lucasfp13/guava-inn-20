FactoryBot.define do
  factory :reservation do
    room
    start_date { rand(0..50).days.ago.to_date }
    start_date { rand(1..50).days.from_now.to_date }
    guest_name { Faker::Name.unique.name }
    number_of_guests { room.present? ? rand(1..room.capacity) : rand(1..10) }
  end
end