class TaskBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :actions, :kind, :navigation_callback, :visibility, :client
end
