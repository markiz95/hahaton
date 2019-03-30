class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :token
      t.datetime :oauth_expires_at
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :last_sign_in_ip
      t.string :current_sign_in_ip
      t.datetime :last_sign_in_at
      t.datetime :current_sign_in_at
      t.integer :sign_in_count

      t.timestamps
    end
  end
end
