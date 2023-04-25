class PoolBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :address

  association :token, blueprint: TokenBlueprint

  view :manager do
    association :pool_balance, blueprint: PoolBalanceBlueprint
  end
end
