class AddLanguageToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :language, :integer, default: 0
  end
end
