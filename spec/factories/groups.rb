# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    hashtag { 'rubykaigi' }
    details { '誰でも参加OK！' }
    capacity { 10 }
    location { '未定' }
    payment_method { '割り勘' }
    association :owner

    trait :invalid do
      hashtag { nil }
    end

    trait :full_capacity do
      capacity { 1 }
      after(:create) do |group|
        create(:ticket, group:)
      end
    end
  end
end
