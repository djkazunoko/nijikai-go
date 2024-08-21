# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider { 'github' }
    sequence(:uid) { |n| "000#{n}" }
    sequence(:name) { |n| "user#{n}" }
    sequence(:image_url) { |n| "https://example.com/user#{n}.png" }

    trait :alice do
      uid { '1111' }
      name { 'alice' }
      image_url { 'https://example.com/alice.png' }
    end
  end
end
