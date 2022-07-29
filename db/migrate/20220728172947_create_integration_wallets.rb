class CreateIntegrationWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :integration_wallets, id: :uuid do |t|
      t.string :public_key, unique: true
      t.string :encrypted_private_key, unique: true
      t.string :private_key_iv, unique: true

      t.references :integration, index: true
    end
  end
end
