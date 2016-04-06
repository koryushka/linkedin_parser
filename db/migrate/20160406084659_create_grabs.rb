class CreateGrabs < ActiveRecord::Migration
  def change
    create_table :grabs do |t|
      t.string :company
      t.string :links

      t.timestamps
    end
  end
end
