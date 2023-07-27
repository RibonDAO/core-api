class PoolBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :address

  association :token, blueprint: TokenBlueprint

  association :pool_balance, blueprint: PoolBalanceBlueprint
end
