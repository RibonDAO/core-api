class TagBlueprint < Blueprinter::Base
  identifier :id


  fields :name, :status, :created_at, :updated_at


  association :non_profits, blueprint: NonProfitBlueprint

end