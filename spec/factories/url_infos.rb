# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :url_info do
    http_code { 200 }
    number_of_checks { 1 }
    last_check { '2014-09-11 20:22:15' }
  end
end
