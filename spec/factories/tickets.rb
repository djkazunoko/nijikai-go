# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    association :user
    association :group
  end
end
