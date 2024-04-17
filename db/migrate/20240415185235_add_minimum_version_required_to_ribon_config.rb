class AddMinimumVersionRequiredToRibonConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :ribon_configs, :minimum_version_required, :string, default: "0.0.0"
  end
end
