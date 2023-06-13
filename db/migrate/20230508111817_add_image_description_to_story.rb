class AddImageDescriptionToStory < ActiveRecord::Migration[7.0]
  def change
    add_column :stories, :image_description, :string
  end
end
