FactoryGirl.define do
  factory :user do
    name 'Joe'
    email 'Joe@example.com'
  end

  factory :w000t do
    long_url 'http://w000t.me'
    short_url 'http://w000t.me'
  end

  factory :bob do
    name 'Bob'
    email 'bob@example.com'
  end
end
