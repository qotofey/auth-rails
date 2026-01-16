class CreateUserSessions < ActiveRecord::Migration[8.2]
  def change
    create_table :user_sessions do |t|
      t.string :token, null: false, index: { unique: true }, limit: 64
      t.datetime :disabled_at
      t.references :user_credential, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
