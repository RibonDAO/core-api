class AddDisableLabelingToRibonConfigs < ActiveRecord::Migration[7.0]
  def change
    add_column :ribon_configs, :disable_labeling, :boolean, default: false
  end
end
