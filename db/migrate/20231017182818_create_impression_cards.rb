class CreateImpressionCards < ActiveRecord::Migration[7.0]
  def change
    create_table :impression_cards do |t|
      t.string :title, null: false, default: ''
      t.string :headline, null: false, default: ''
      t.string :description, null: false, default: ''
      t.string :video_url, null: true
      t.string :cta_text, null: false, default: ''
      t.string :cta_url, null: false, default: ''
      
      t.timestamps
    end
  end
end
