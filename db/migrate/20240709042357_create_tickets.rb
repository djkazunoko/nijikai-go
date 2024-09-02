class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :tickets, %i[group_id user_id], unique: true
  end
end
