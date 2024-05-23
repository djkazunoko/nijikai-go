# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider { 'github' }
    uid { '0001' }
    name { 'tester1' }
    image_url { 'example.com/1' }
  end
end
