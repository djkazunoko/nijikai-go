# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:hashtag) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:capacity) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:payment_method) }
    it { is_expected.to validate_numericality_of(:capacity).only_integer }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_length_of(:hashtag).is_at_most(50) }
    it { is_expected.to validate_length_of(:details).is_at_most(2000) }
    it { is_expected.to validate_length_of(:location).is_at_most(100) }
    it { is_expected.to validate_length_of(:payment_method).is_at_most(50) }
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

  describe '#remaining_slots' do
    let(:group) { create(:group, capacity: 3) }

    context 'when there are no participants' do
      it 'returns the capacity' do
        expect(group.remaining_slots).to eq 3
      end
    end

    context 'when there are some participants' do
      it 'returns the number of remaining slots' do
        create_list(:ticket, 2, group:)
        expect(group.remaining_slots).to eq 1
      end
    end

    context 'when the group is full' do
      it 'returns 0' do
        create_list(:ticket, 3, group:)
        expect(group.remaining_slots).to eq 0
      end
    end
  end
end
