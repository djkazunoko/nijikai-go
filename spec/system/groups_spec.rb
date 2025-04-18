# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups', type: :system do
  describe 'group index page' do
    context 'when there are no groups' do
      it 'displays a no groups message' do
        visit groups_path
        expect(page).to have_content 'まだ2次会グループはありません。'
      end
    end

    context 'when there are groups' do
      let!(:groups) { create_list(:group, 2) }
      let(:group) { groups.first }

      before do
        create(:post, group:)
      end

      it 'displays a list of groups' do
        visit groups_path
        expect(page).to have_content "##{group.hashtag}の2次会一覧"
        within all('.group').first do
          expect(page).to have_css("img[src='#{group.owner.image_url}']")
          expect(page).to have_link href: "https://github.com/#{group.owner.name}"
          expect(page).to have_link(group.details, href: group_path(group))
          expect(page).to have_content group.location
          expect(page).to have_content group.payment_method
          expect(page).to have_content "#{group.tickets.count}名 / #{group.capacity}名"
          expect(page).to have_content "コメント(#{group.posts.count})"
        end
        within all('.group').last do
          expect(page).not_to have_content 'コメント'
        end
        expect(page).to have_css('.group', count: groups.count)
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'displays create group button' do
        visit groups_path
        expect(page).to have_link '2次会グループを作成'
      end
    end

    context 'when user is not logged in' do
      it 'displays log in and create group button' do
        visit groups_path
        expect(page).to have_button 'GitHubアカウントでログイン'
      end
    end
  end

  describe 'group page' do
    let(:group) { create(:group) }

    it 'displays the group' do
      visit group_path(group)
      expect(page).to have_link(href: "https://github.com/#{group.owner.name}")
      expect(page).to have_content group.hashtag
      within('.group-details') do
        expect(page).to have_content group.details
        expect(page).to have_content group.location
        expect(page).to have_content group.payment_method
      end
      expect(page).not_to have_css('.participants')
      expect(page).to have_css('.participation-action-item')
    end

    context 'when owner' do
      before do
        login_as(group.owner)
      end

      it 'display edit and delete links' do
        visit group_path(group)
        expect(page).to have_link('内容修正')
        expect(page).to have_button('削除する')
      end
    end

    context 'when other user' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'does not display edit and delete links' do
        visit group_path(group)
        expect(page).not_to have_link('内容修正')
        expect(page).not_to have_button('削除する')
      end
    end

    context 'when guest' do
      it 'does not display edit and delete links' do
        visit group_path(group)
        expect(page).not_to have_link('内容修正')
        expect(page).not_to have_button('削除する')
      end
    end

    context 'when group has participants' do
      let(:group_with_4_participants) { create(:group) }
      let(:group_with_6_participants) { create(:group) }

      before do
        create_list(:ticket, 4, group: group_with_4_participants)
        create_list(:ticket, 6, group: group_with_6_participants)
      end

      it 'displays all participant icons when there are 5 or fewer participants' do
        visit group_path(group_with_4_participants)
        within('.participants') do
          group_with_4_participants.tickets.each do |ticket|
            expect(page).to have_css("a[href='https://github.com/#{ticket.user.name}']")
          end
        end
      end

      it 'displays up to 5 participant icons when there are more than 5 participants' do
        visit group_path(group_with_6_participants)
        within('.participants') do
          group_with_6_participants.tickets.first(5).each do |ticket|
            expect(page).to have_css("a[href='https://github.com/#{ticket.user.name}']")
          end
          expect(page).not_to have_css("a[href='https://github.com/#{group_with_6_participants.tickets.last.user.name}']")
        end
      end

      it 'displays all participant icons and names in the modal' do
        visit group_path(group_with_6_participants)
        click_button 'すべて見る'

        within('dialog#modal.modal') do
          group_with_6_participants.tickets.each do |ticket|
            expect(page).to have_css("a[href='https://github.com/#{ticket.user.name}']")
            expect(page).to have_css("img[src='#{ticket.user.image_url}']")
            expect(page).to have_content(ticket.user.name)
          end
        end
      end
    end
  end

  describe 'new group page' do
    context 'when user is logged in' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'displays a form to create a new group' do
        visit groups_path
        click_link '2次会グループを作成'
        expect(page).to have_current_path(new_group_path)
        expect(page).to have_content '2次会グループ作成'
        expect(page).to have_field 'イベントのハッシュタグ'
        expect(page).to have_field '募集内容', with: '誰でも参加OK！'
        expect(page).to have_field '定員', with: 10
        expect(page).to have_field '会場', with: '未定'
        expect(page).to have_field '会計方法', with: '割り勘'
        expect(page).to have_button '2次会グループを作成'
        expect(page).to have_link('キャンセル', href: groups_path)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root_path' do
        visit new_group_path
        expect(page).to have_content 'ログインしてください。'
        expect(page).to have_current_path(root_path)
      end
    end
  end

  describe 'creating a new group' do
    let(:user) { create(:user) }

    before do
      github_mock(user)
      visit groups_path
      click_button 'GitHubアカウントでログイン'
    end

    context 'with valid input' do
      it 'creates the group' do
        expect(page).to have_current_path(new_group_path)
        expect do
          fill_in 'イベントのハッシュタグ', with: 'rubykaigi'
          fill_in '募集内容', with: '誰でも参加OK！'
          fill_in '定員', with: 10
          fill_in '会場', with: '未定'
          fill_in '会計方法', with: '割り勘'
          click_button '2次会グループを作成'

          expect(page).to have_content '2次会グループが作成されました。'
        end.to change(Group, :count).by(1)

        expect(page).to have_current_path(group_path(Group.last))
      end
    end

    context 'with invalid input' do
      it 'displays an error message and does not create the group' do
        expect(page).to have_current_path(new_group_path)
        expect do
          fill_in 'イベントのハッシュタグ', with: ''
          fill_in '募集内容', with: '誰でも参加OK！'
          fill_in '定員', with: 10
          fill_in '会場', with: '未定'
          fill_in '会計方法', with: '割り勘'
          click_button '2次会グループを作成'

          expect(page).to have_content '入力内容にエラーがありました。'
          expect(page).to have_content 'イベントのハッシュタグを入力してください'
        end.not_to change(Group, :count)

        expect(page).to have_current_path(new_group_path)
      end
    end
  end

  describe 'edit group page' do
    let(:group) { create(:group) }

    context 'when owner' do
      before do
        login_as(group.owner)
      end

      it 'displays a form to edit the group' do
        visit edit_group_path(group)
        expect(page).to have_content '2次会グループ編集'
        expect(page).to have_field 'イベントのハッシュタグ', with: group.hashtag
        expect(page).to have_field '募集内容', with: group.details
        expect(page).to have_field '定員', with: group.capacity
        expect(page).to have_field '会場', with: group.location
        expect(page).to have_field '会計方法', with: group.payment_method
        expect(page).to have_button '内容を更新'
      end
    end

    context 'when other user' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'returns a 404 response' do
        visit edit_group_path(group)
        expect(page).to have_content 'ActiveRecord::RecordNotFound'
      end
    end

    context 'when guest' do
      it 'redirects to root_path' do
        visit edit_group_path(group)
        expect(page).to have_content 'ログインしてください。'
        expect(page).to have_current_path(root_path)
      end
    end
  end

  describe 'updating a group' do
    let(:group) { create(:group) }

    before do
      login_as(group.owner)
      visit group_path(group)
      click_link '内容修正'
    end

    context 'with valid input' do
      it 'updates the group' do
        expect(page).to have_current_path(edit_group_path(group))

        fill_in '会場', with: 'とある居酒屋'
        click_button '内容を更新'

        expect(page).to have_content '2次会グループが更新されました。'
        expect(page).to have_content 'とある居酒屋'
        expect(page).to have_current_path(group_path(group))
      end
    end

    context 'with invalid input' do
      it 'displays an error message and does not update the group' do
        expect(page).to have_current_path(edit_group_path(group))

        fill_in '会場', with: ''
        click_button '内容を更新'

        expect(page).to have_content '入力内容にエラーがありました。'
        expect(page).to have_content '会場を入力してください'
        expect(page).to have_current_path(edit_group_path(group))
      end

      it 'does not allow setting capacity less than the number of participants' do
        create_list(:ticket, 2, group:)

        expect(page).to have_current_path(edit_group_path(group))

        fill_in '定員', with: '1'
        click_button '内容を更新'

        expect(page).to have_content '入力内容にエラーがありました。'
        expect(page).to have_content '定員は参加人数以上の値にしてください'
        expect(page).to have_current_path(edit_group_path(group))
      end
    end
  end

  describe 'deleting a group' do
    let(:group) { create(:group) }

    before do
      login_as(group.owner)
    end

    it 'deletes the group' do
      visit group_path(group)

      expect do
        accept_confirm do
          click_button '削除する'
        end

        expect(page).to have_content '2次会グループが削除されました。'
      end.to change(Group, :count).by(-1)

      expect(page).to have_current_path(groups_path)
    end
  end
end
