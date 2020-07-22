FactoryBot.define do
  factory :room do
    sequence(:code, '01')
    capacity { rand(1..10) }
    notes { Faker::Lorem.sentence(word_count: 6) }
  end
end