# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe '#hashtag_format' do
    let(:group) { build(:group) }

    it 'is valid with a valid hashtag' do
      group.hashtag = 'validHashtag'
      expect(group).to be_valid
    end

    it 'is valid with a hashtag starting with #' do
      group.hashtag = '#validHashtag'
      expect(group).to be_valid
    end

    it 'is invalid with a hashtag starting with multiple #' do
      group.hashtag = '##invalidHashtag'
      expect(group).to be_invalid
    end

    it 'is invalid with a hashtag containing spaces' do
      group.hashtag = 'invalid hashtag'
      expect(group).to be_invalid
      expect(group.errors[:hashtag]).to include('にはスペースや記号は使用できません。')
    end

    it 'is invalid with a hashtag containing special characters' do
      group.hashtag = 'invalid@hashtag'
      expect(group).to be_invalid
      expect(group.errors[:hashtag]).to include('にはスペースや記号は使用できません。')
    end
  end

  describe '#hashtag_cannot_be_numbers_or_underscores_only' do
    let(:group) { build(:group) }

    it 'is invalid with a hashtag containing only numbers' do
      group.hashtag = '123'
      expect(group).to be_invalid
      expect(group.errors[:hashtag]).to include('は数字、アンダースコアのみでは登録できません')
    end

    it 'is invalid with a hashtag containing only underscores' do
      group.hashtag = '_'
      expect(group).to be_invalid
      expect(group.errors[:hashtag]).to include('は数字、アンダースコアのみでは登録できません')
    end

    it 'is invalid with a hashtag containing only numbers and underscores' do
      group.hashtag = '123_'
      expect(group).to be_invalid
      expect(group.errors[:hashtag]).to include('は数字、アンダースコアのみでは登録できません')
    end

    it 'is valid with a hashtag containing letters and numbers' do
      group.hashtag = 'valid123'
      expect(group).to be_valid
    end
  end

  describe '#remove_leading_hash_from_hashtag' do
    let(:group) { build(:group) }

    it 'removes leading # from hashtag before save' do
      group.hashtag = '#validHashtag'
      group.save
      expect(group.hashtag).to eq('validHashtag')
    end
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
