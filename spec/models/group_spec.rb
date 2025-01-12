# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:group) { build(:group) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:hashtag) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:capacity) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:payment_method) }
    it { is_expected.to validate_numericality_of(:capacity).only_integer }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
  end
end
