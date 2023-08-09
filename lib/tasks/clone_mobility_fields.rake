desc 'Clone impact descriptions from nonprofit to nonprofit impacts'
namespace :mobility do
  task clone_fields: :environment do
    NonProfit.all.each do |non_profit|
      non_profit_impact = non_profit.non_profit_impacts.last
      next if non_profit_impact.blank?

      non_profit_impact.update(
        impact_description_en: non_profit.impact_description_en,
        impact_description_pt_br: non_profit.impact_description_pt_br
      )
    end
  end
end
