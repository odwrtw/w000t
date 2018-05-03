# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :user do
    email 'bob@test.com'
    password 'testtesttest'
    pseudo 'superBob'
  end
end
