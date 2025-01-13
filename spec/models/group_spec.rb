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

  describe '#created_by?' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:group) { create(:group, owner:) }

    context 'when the user is the owner of the group' do
      it 'returns true' do
        expect(group.created_by?(owner)).to be true
      end
    end

    context 'when the user is not the owner of the group' do
      it 'returns false' do
        expect(group.created_by?(other_user)).to be false
      end
    end

    context 'when the user is nil' do
      it 'returns false' do
        expect(group.created_by?(nil)).to be false
      end
    end
  end

  describe '#full_capacity?' do
    let(:group) { create(:group, capacity: 3) }

    context 'when the group has not reached capacity' do
      it 'returns false' do
        create_list(:ticket, 2, group:)
        expect(group.full_capacity?).to be false
      end
    end

    context 'when the group has reached capacity' do
      it 'returns true' do
        create_list(:ticket, 3, group:)
        expect(group.full_capacity?).to be true
      end
    end
  end
end
