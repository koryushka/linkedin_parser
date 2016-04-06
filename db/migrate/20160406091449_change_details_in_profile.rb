class ChangeDetailsInProfile < ActiveRecord::Migration
  def change
    remove_column :grabs, :links, :string
    add_column :grabs, :links, :text
  end
end
