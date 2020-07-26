FactoryBot.define do
  factory :reservation do
    room
    start_date { rand(0..20).days.ago.to_date }
    end_date { rand(1..50).days.from_now.to_date }
    guest_name { Faker::Name.unique.name }
    number_of_guests { room.present? ? rand(1..room.capacity) : rand(1..10) }

    transient do
      in_room { {} }
    end

    after(:build) do |reservation, evaluator|
      if evaluator.in_room.present?
        reservation.room = build(:room, evaluator.in_room)
      end
    end
  end
end