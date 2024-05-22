class CreateNonProfitTags < ActiveRecord::Migration[7.0]
  def change
    create_table :non_profit_tags do |t|
      t.references :non_profit, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
