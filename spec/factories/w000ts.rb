# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :w000t do
    long_url 'http://w000t.me'

    initialize_with { new(long_url: long_url) }
  end
end
