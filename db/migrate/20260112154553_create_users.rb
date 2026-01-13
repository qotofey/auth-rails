class CreateUsers < ActiveRecord::Migration[8.2]
  def change
    create_table :users do |t|
      t.string :name, limit: 64
      t.string :middle_name, limit: 64
      t.string :last_name, limit: 64
      t.string :gender, limit: 16
      t.date :birth_date
      t.datetime :blocked_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
