class ReportBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :link, :active, :created_at, :updated_at
end