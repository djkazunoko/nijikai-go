# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups', type: :system do
  let(:group) { create(:group) }
  let(:bob) { build(:user, :bob) }

  describe 'creating a new group' do
    before do
      github_mock(bob)
    end

    context 'with valid input' do
      it 'creates the group' do
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
        expect(page).to have_current_path(new_group_path)

        expect do
          fill_in 'イベントのハッシュタグ', with: 'rubykaigi'
          fill_in '2次会グループ名', with: 'みんなで飲みましょう!!'
          fill_in '募集内容', with: '誰でも参加OK!!'
          fill_in '定員', with: 10
          fill_in '会場', with: '未定'
          fill_in '会計方法', with: '割り勘'
          click_button '登録する'

          expect(page).to have_content '2次会グループが作成されました'
          expect(page).to have_content 'rubykaigi'
          expect(page).to have_current_path(group_path(Group.last))
        end.to change(Group, :count).by(1)
      end
    end

    context 'with invalid input' do
      it 'displays an error message' do
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
        expect(page).to have_current_path(new_group_path)

        expect do
          fill_in 'イベントのハッシュタグ', with: ''
          fill_in '2次会グループ名', with: 'みんなで飲みましょう!!'
          fill_in '募集内容', with: '誰でも参加OK!!'
          fill_in '定員', with: 10
          fill_in '会場', with: '未定'
          fill_in '会計方法', with: '割り勘'
          click_button '登録する'

          expect(page).to have_content '2次会グループに1個のエラーが発生しました'
          expect(page).to have_content 'イベントのハッシュタグを入力してください'
          expect(page).to have_current_path(new_group_path)
        end.not_to change(Group, :count)
      end
    end

    context 'when guest' do
      it 'redirects to root_path' do
        visit new_group_path
        expect(page).to have_content 'ログインしてください'
        expect(page).to have_current_path(root_path)
      end
    end
  end

  describe 'updating a group' do
    context 'when owner' do
      before do
        github_mock(group.owner)
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
      end

      it 'updates the group with valid input' do
        visit group_path(group)
        click_link '編集'
        expect(page).to have_current_path(edit_group_path(group))

        fill_in '会場', with: 'とある居酒屋'
        click_button '更新する'

        expect(page).to have_content '2次会グループが更新されました'
        expect(page).to have_content 'とある居酒屋'
        expect(page).to have_current_path(group_path(group))
      end

      it 'displays an error message with invalid input' do
        visit group_path(group)
        click_link '編集'
        expect(page).to have_current_path(edit_group_path(group))

        fill_in '会場', with: ''
        click_button '更新する'

        expect(page).to have_content '2次会グループに1個のエラーが発生しました'
        expect(page).to have_content '会場を入力してください'
        expect(page).to have_current_path(edit_group_path(group))
      end
    end

    context 'when other user' do
      before do
        github_mock(bob)
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
      end

      it 'does not display edit and delete link' do
        visit group_path(group)
        expect(page).not_to have_link('編集')
        expect(page).not_to have_button('削除')
      end

      it 'returns a 404 response' do
        visit edit_group_path(group)
        expect(page).to have_content 'ActiveRecord::RecordNotFound'
      end
    end

    context 'when guest' do
      it 'does not display edit and delete links' do
        visit group_path(group)
        expect(page).not_to have_link('編集')
        expect(page).not_to have_button('削除')
      end

      it 'redirects to root_path' do
        visit edit_group_path(group)
        expect(page).to have_content 'ログインしてください'
        expect(page).to have_current_path(root_path)
      end
    end
  end

  describe 'deleting a group' do
    context 'when owner' do
      before do
        github_mock(group.owner)
        visit root_path
        click_button 'サインアップ / ログインをして2次会グループを作成'
      end

      it 'deletes the group' do
        visit group_path(group)

        expect do
          accept_confirm do
            click_button '削除'
          end

          expect(page).to have_content '2次会グループが削除されました'
          expect(page).not_to have_content 'rubykaigi'
          expect(page).to have_current_path(groups_path)
        end.to change(Group, :count).by(-1)
      end
    end
  end
end
