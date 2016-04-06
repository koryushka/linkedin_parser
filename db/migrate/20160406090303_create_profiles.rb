class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :company_name
      t.string :company_url
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :title
      t.string :location
      t.string :url
      t.references :grab, index: true

      t.timestamps
    end
  end
end
