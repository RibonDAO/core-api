class PopulateEnNamesForNonProfits < ActiveRecord::Migration[7.0]
  def change
     NonProfit.all.each do |non_profit|
      non_profit.name_en = non_profit.name_for_database
      non_profit.name_pt_br = non_profit.name_for_database
      non_profit.save
    end
  end
end
