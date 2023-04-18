class AddLanguageToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :language, :integer, default: 0
  end
end
