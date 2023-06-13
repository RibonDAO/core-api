class AuthorBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :created_at, :updated_at

  view :minimal do
    excludes :created_at, :updated_at
  end
end
