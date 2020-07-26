FactoryBot.define do
  factory :room do
    sequence(:code, '01')
    capacity { rand(1..10) }
    notes { Faker::Lorem.sentence(word_count: 6) }

    transient do
      with_reservations { [] }
    end

    after(:build) do |room, evaluator|
      if evaluator.with_reservations.present?
        reservations = evaluator.with_reservations

        reservations.each do |reservation|
          reservation[:room] = room
          create(:reservation, reservation)
        end
      end
    end
  end
end