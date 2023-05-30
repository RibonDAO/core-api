class ContributionBlueprint < Blueprinter::Base
  identifier :id

  association :person_payment, blueprint: PersonPaymentBlueprint

  view :non_profit do
    association :receiver, blueprint: NonProfitBlueprint
  end

  view :cause do
    association :receiver, blueprint: CauseBlueprint
  end
end
