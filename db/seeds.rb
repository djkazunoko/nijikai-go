# frozen_string_literal: true

users_data = (1..50).map do |i|
  { provider: 'github', uid: i.to_s, name: "user#{i}", image_url: "https://picsum.photos/id/#{i}/200" }
end

users = users_data.map { |user_data| User.create!(user_data) }

groups_data = [
  { hashtag: 'rubykaigi', details: '誰でも参加OK!!', capacity: 2, location: '未定', payment_method: '割り勘', owner_id: users[0].id },
  { hashtag: 'rubykaigi', details: 'サシで話したい', capacity: 1, location: '未定', payment_method: '奢ります', owner_id: users[1].id },
  { hashtag: 'rubykaigi', details: 'Anyone who loves Ruby is welcome to join', capacity: 10, location: 'Somewhere in Japan',
    payment_method: 'split bill', owner_id: users[2].id },
  { hashtag: 'bigparty', details: 'みんなで楽しく飲みましょう！', capacity: 100, location: '未定', payment_method: '割り勘', owner_id: users[0].id }
]

groups = groups_data.map { |group_data| Group.create!(group_data) }

Ticket.create!(user: users[1], group: groups[0])
Ticket.create!(user: users[2], group: groups[0])
Ticket.create!(user: users[0], group: groups[2])
Ticket.create!(user: users[1], group: groups[2])
(2..50).each do |i|
  Ticket.create!(user: users[i - 1], group: groups[3])
end

groups.first(2).each do |group|
  users.first(10).each do |user|
    Post.create!(user:, group:, content: "Hello! by #{user.name}")
  end
end
