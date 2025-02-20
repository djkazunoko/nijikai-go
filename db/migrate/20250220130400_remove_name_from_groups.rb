class RemoveNameFromGroups < ActiveRecord::Migration[7.1]
  def change
    remove_column :groups, :name, :string
  end
end
