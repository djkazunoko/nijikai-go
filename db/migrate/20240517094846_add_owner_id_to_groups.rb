class AddOwnerIdToGroups < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :owner, foreign_key: { to_table: :users }, null: false
  end
end
