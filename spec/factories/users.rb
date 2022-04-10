FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "name#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    add_attribute(:alias) { 'name_alias' }
    password { 'P@ssw0rd' }
    password_confirmation { 'P@ssw0rd' }
  end
end
