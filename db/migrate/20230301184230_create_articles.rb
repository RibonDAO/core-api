class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.references :author, null: false, foreign_key: true
      t.string :title
      t.timestamp :published_at
      t.boolean :visible

      t.timestamps
    end
  end
end
