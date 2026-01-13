class CreateUserCredentials < ActiveRecord::Migration[8.2]
  def change
    create_table :user_credentials do |t|
      t.string :kind, limit: 16
      t.string :login, index: { unique: true }
      t.datetime :confirmed_at
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    create_table :user_passwords do |t|
      t.string :password_digest, null: false
      t.datetime :disabled_at
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
