FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "name#{n}" }
  end
end
