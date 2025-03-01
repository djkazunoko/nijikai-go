# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :system do
  shared_context 'when the user is logged in' do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end
  end

  shared_context 'when the user is NOT logged in' do
    let(:user) { create(:user) }

    before do
      github_mock(user)
    end
  end

  shared_context 'when the user is the owner of the group' do
    let(:group) { create(:group, owner: user) }
  end

  shared_context 'when the user is NOT the owner of the group' do
    let(:group) { create(:group) }
  end

  shared_context 'when the user is a member of the group' do
    before do
      create(:ticket, user:, group:)
    end
  end

  describe 'group participation by logged in user' do
    include_context 'when the user is logged in'
    context 'when the user is the owner of the group' do
      include_context 'when the user is the owner of the group'

      it 'does not display participation buttons and messages' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_button '参加をキャンセルする'
        expect(page).not_to have_content '定員に達したため参加できません'
      end
    end

    context 'when the user is NOT the owner of the group AND is a member of the group AND the group is full' do
      include_context 'when the user is NOT the owner of the group'
      include_context 'when the user is a member of the group'
      before do
        group.update!(capacity: 1)
      end

      it 'displays a cancel button and allows cancellation' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_content '定員に達したため参加できません'

        within('.participants') do
          expect(page).to have_link href: "https://github.com/#{user.name}"
          expect(page).to have_content '1人の参加者'
        end

        expect do
          click_button '参加をキャンセルする'
          expect(page).to have_content 'この2次会グループの参加をキャンセルしました'
          expect(page).not_to have_css('.participants')
          expect(page).to have_button 'この2次会グループに参加する'
        end.to change(Ticket, :count).by(-1)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when the user is NOT the owner of the group AND is a member of the group AND the group is NOT full' do
      include_context 'when the user is NOT the owner of the group'
      include_context 'when the user is a member of the group'

      it 'displays a cancel button and allows cancellation' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_content '定員に達したため参加できません'

        within('.participants') do
          expect(page).to have_link href: "https://github.com/#{user.name}"
          expect(page).to have_content '1人の参加者'
        end

        expect do
          click_button '参加をキャンセルする'
          expect(page).to have_content 'この2次会グループの参加をキャンセルしました'
          expect(page).not_to have_css('.participants')
          expect(page).to have_button 'この2次会グループに参加する'
        end.to change(Ticket, :count).by(-1)

        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when the user is NOT the owner of the group AND is NOT a member of the group AND the group is full' do
      include_context 'when the user is NOT the owner of the group'
      before do
        create_list(:ticket, 10, group:)
      end

      it 'displays a full capacity message' do
        visit group_path(group)

        expect(page).to have_content '定員に達したため参加できません'

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_button '参加をキャンセルする'
      end
    end

    context 'when the user is NOT the owner of the group AND is NOT a member of the group AND the group is NOT full' do
      include_context 'when the user is NOT the owner of the group'

      it 'displays a participation button and allows participation' do
        visit group_path(group)

        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_button '参加をキャンセルする'
        expect(page).not_to have_content '定員に達したため参加できません'

        expect(page).not_to have_css('.participants')

        expect do
          click_button 'この2次会グループに参加する'
          expect(page).to have_content '2次会グループに参加しました'
          within('.participants') do
            expect(page).to have_link href: "https://github.com/#{user.name}"
            expect(page).to have_content '1人の参加者'
          end
          expect(page).to have_button '参加をキャンセルする'
        end.to change(Ticket, :count).by(1)

        expect(page).to have_current_path(group_path(group))
      end
    end
  end

  describe 'group participation by non logged in user' do
    include_context 'when the user is NOT logged in'
    context 'when the group is full' do
      let(:full_capacity_group) { create(:group, :full_capacity) }

      it 'displays a full capacity message' do
        visit group_path(full_capacity_group)

        expect(page).to have_content '定員に達したため参加できません'

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_button '参加をキャンセルする'
      end
    end

    context 'when the user is the owner of the group AND is NOT a member of the group AND the group is NOT full' do
      include_context 'when the user is the owner of the group'

      it 'displays a log in and participation button but prevents participation for the owner' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button '参加をキャンセルする'
        expect(page).not_to have_content '定員に達したため参加できません'

        expect(page).not_to have_css('.avatar')

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content '自身が主催したグループには参加できません'
        end.not_to change(Ticket, :count)

        expect(page).to have_css(".avatar img[src='#{user.image_url}']")
        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when the user is NOT the owner of the group AND is a member of the group AND the group is NOT full' do
      include_context 'when the user is NOT the owner of the group'
      include_context 'when the user is a member of the group'

      it 'displays a log in and participation button but prevents participation for members' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button '参加をキャンセルする'
        expect(page).not_to have_content '定員に達したため参加できません'

        expect(page).not_to have_css('.avatar')

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content 'この2次会グループには既に参加しています'
        end.not_to change(Ticket, :count)

        expect(page).to have_css(".avatar img[src='#{user.image_url}']")
        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'when the user is NOT the owner of the group AND is NOT a member of the group AND the group is NOT full' do
      include_context 'when the user is NOT the owner of the group'

      it 'displays a log in and participation button and allows participation' do
        visit group_path(group)

        expect(page).not_to have_button 'この2次会グループに参加する'
        expect(page).not_to have_button '参加をキャンセルする'
        expect(page).not_to have_content '定員に達したため参加できません'

        expect(page).not_to have_css('.avatar')

        expect(page).not_to have_css('.participants')

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content '2次会グループに参加しました'
          within('.participants') do
            expect(page).to have_link href: "https://github.com/#{user.name}"
            expect(page).to have_content '1人の参加者'
          end
          expect(page).to have_button '参加をキャンセルする'
        end.to change(Ticket, :count).by(1)

        expect(page).to have_css(".avatar img[src='#{user.image_url}']")
        expect(page).to have_current_path(group_path(group))
      end
    end
  end
end
