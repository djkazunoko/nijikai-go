# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider { 'github' }
    uid { '0001' }
    name { 'alice' }
    image_url { 'https://example.com/alice.png' }

    trait :bob do
      uid { '0002' }
      name { 'bob' }
      image_url { 'https://example.com/bob.png' }
    end
  end
end
