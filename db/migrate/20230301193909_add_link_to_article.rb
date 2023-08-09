class AddLinkToArticle < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :link, :string
  end
end
