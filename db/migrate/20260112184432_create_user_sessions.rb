class CreateUserSessions < ActiveRecord::Migration[8.2]
  def change
    create_table :user_sessions do |t|
      t.string :refresh_token
      t.datetime :disabled_at
      t.references :user_credential, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
