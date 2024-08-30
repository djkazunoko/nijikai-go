# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :system do
  let(:alice) { build(:user, :alice) }
  let(:group) { create(:group) }

  describe 'group participation' do
    context 'when not logged in' do
      before do
        github_mock(alice)
      end

      it 'logs in and allows the user to join the group' do
        visit group_path(group)

        expect(page).not_to have_css('.avatar')
        expect(page).not_to have_link href: "https://github.com/#{alice.name}"
        expect(page).to have_content "0 / #{group.capacity}人"
        expect(page).not_to have_button '参加をキャンセルする'

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content '2次会グループに参加しました'
          expect(page).to have_css(".avatar img[src='#{alice.image_url}']")
          expect(page).to have_link href: "https://github.com/#{alice.name}"
          expect(page).to have_content "1 / #{group.capacity}人"
          expect(page).to have_button '参加をキャンセルする'
        end.to change(Ticket, :count).by(1)
      end
    end

    context 'when logged in and meeting the participation requirements' do
      before do
        github_mock(alice)
        visit '/auth/github/callback'
      end

      it 'allows the user to join the group' do
        visit group_path(group)

        expect(page).not_to have_link href: "https://github.com/#{alice.name}"
        expect(page).to have_content "0 / #{group.capacity}人"
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).not_to have_button '参加をキャンセルする'

        expect do
          click_button 'この2次会グループに参加する'
          expect(page).to have_content '2次会グループに参加しました'
          expect(page).to have_link href: "https://github.com/#{alice.name}"
          expect(page).to have_content "1 / #{group.capacity}人"
          expect(page).to have_button '参加をキャンセルする'
        end.to change(Ticket, :count).by(1)
      end
    end

    context 'when already participating in the group and not logged in' do
      before do
        github_mock(alice)
        create(:ticket, user: alice, group:)
      end

      it 'does not allow the user to join the group' do
        visit group_path(group)

        expect(page).to have_link href: "https://github.com/#{alice.name}"

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content 'この2次会グループには既に参加しています'
        end.not_to change(Ticket, :count)
      end
    end

    context 'when the group has reached its capacity' do
      let(:full_capacity_group) { create(:group, :full_capacity) }

      it 'does not display participation button' do
        visit group_path(full_capacity_group)
        expect(page).not_to have_button 'サインアップ / ログインをして2次会グループに参加'
        expect(page).to have_content '定員に達したため参加できません'
      end
    end

    context 'when the user is the group owner and logged in' do
      before do
        github_mock(group.owner)
        visit '/auth/github/callback'
      end

      it 'does not display participation button' do
        visit group_path(group)
        expect(page).not_to have_button 'この2次会グループに参加する'
      end
    end

    context 'when the user is the group owner and not logged in' do
      before do
        github_mock(group.owner)
      end

      it 'does not allow the user to join the group' do
        visit group_path(group)

        expect do
          click_button 'サインアップ / ログインをして2次会グループに参加'
          expect(page).to have_content '自身が主催したグループには参加できません'
        end.not_to change(Ticket, :count)
      end
    end
  end

  describe 'group participation cancellation' do
    before do
      github_mock(alice)
    end

    it 'allows the user to cancel participation' do
      visit group_path(group)
      click_button 'サインアップ / ログインをして2次会グループに参加'

      expect(page).to have_link href: "https://github.com/#{alice.name}"
      expect(page).to have_content "1 / #{group.capacity}人"

      expect do
        click_button '参加をキャンセルする'
        expect(page).to have_content 'この2次会グループの参加をキャンセルしました'
        expect(page).not_to have_link href: "https://github.com/#{alice.name}"
        expect(page).to have_content "0 / #{group.capacity}人"
        expect(page).to have_button 'この2次会グループに参加する'
      end.to change(Ticket, :count).by(-1)
    end
  end
end
