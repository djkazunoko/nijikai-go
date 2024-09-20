# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    user { nil }
    group { nil }
    content { "MyText" }
  end
end
