class ContributionBlueprint < Blueprinter::Base
  identifier :id

  fields :created_at, :updated_at, :generated_fee_cents,
         :liquid_value_cents, :usd_value_cents, :label

  association :person_payment, blueprint: PersonPaymentBlueprint
  association :contribution_balance, blueprint: ContributionBalanceBlueprint

  view :with_stats do
    field(:stats) do |contribution|
      ContributionStatsBlueprint.render_as_json(Service::Contributions::StatisticsService
                                          .new(contribution:).formatted_statistics)
    end

    association :receiver, blueprint: CauseBlueprint, view: :data_and_images
  end

  view :non_profit do
    association :receiver, blueprint: NonProfitBlueprint
  end

  view :cause do
    association :receiver, blueprint: CauseBlueprint
  end
end
