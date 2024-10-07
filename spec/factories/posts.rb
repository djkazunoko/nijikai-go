# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    content { 'MyText' }
    association :user
    association :group
  end
end
