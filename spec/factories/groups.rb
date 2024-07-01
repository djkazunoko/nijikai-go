# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    hashtag { 'rubykaigi' }
    name { 'みんなで飲みましょう!!' }
    details { '誰でも参加OK!!' }
    capacity { 10 }
    location { '未定' }
    payment_method { '割り勘' }
    association :owner

    trait :invalid do
      hashtag { nil }
    end
  end
end
