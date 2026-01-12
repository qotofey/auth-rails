class CreateUsers < ActiveRecord::Migration[8.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.date :birth_date
      t.datetime :blocked_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
