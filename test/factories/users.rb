# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email 'bob@test.com'
    password 'testtesttest'
    pseudo 'superBob'
  end
end
