class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :email

  view :extended do
    fields :last_donation_at, :last_donated_cause

    field(:company) do |object|
      IntegrationBlueprint.render_as_hash(object.company) if object.company
    end
  end
end
