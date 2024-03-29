class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :email

  view :extended do
    fields :last_donation_at, :last_donated_cause
  end
end
