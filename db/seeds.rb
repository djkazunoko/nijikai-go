# frozen_string_literal: true

users_data = [
  { provider: 'github', uid: '1111', name: 'user1', image_url: 'https://picsum.photos/id/0/200' },
  { provider: 'github', uid: '2222', name: 'user2', image_url: 'https://picsum.photos/id/20/200' },
  { provider: 'github', uid: '3333', name: 'user3', image_url: 'https://picsum.photos/id/28/200' }
]

users = users_data.map { |user_data| User.create!(user_data) }

groups_data = [
  { name: 'みんなで飲みましょう!!', hashtag: 'rubykaigi', details: '誰でも参加OK!!', capacity: 2, location: '未定', payment_method: '割り勘', owner_id: users[0].id },
  { name: 'Railsの話がしたい', hashtag: 'kaigionrails', details: 'サシで話したい', capacity: 1, location: '未定', payment_method: '奢ります', owner_id: users[1].id },
  { name: 'Gather! Rubyists!', hashtag: 'rubyworld', details: 'Anyone who loves Ruby is welcome to join', capacity: 10, location: 'Somewhere in Japan',
    payment_method: 'split bill', owner_id: users[2].id }
]

groups = groups_data.map { |group_data| Group.create!(group_data) }

Ticket.create!(user: users[1], group: groups[0])
Ticket.create!(user: users[2], group: groups[0])
Ticket.create!(user: users[0], group: groups[2])
Ticket.create!(user: users[1], group: groups[2])

groups.first(2).each do |group|
  users.each do |user|
    Post.create!(user:, group:, content: "Hello! by #{user.name}")
  end
end
