class AddDescriptionsToCause < ActiveRecord::Migration[7.0]
  def change
    add_column :causes, :cover_image_description, :string
    add_column :causes, :main_image_description, :string
  end
end
