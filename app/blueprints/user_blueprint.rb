class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :updated_at, :created_at, :email

  view :extended do
    fields :last_donation_at, :last_donated_cause, :language, :legacy_id

    field(:company) do |user|
      IntegrationBlueprint.render_as_hash(user.company, view: :minimal) if user.company
    end

    field(:direct_transfer_subscription) do |user|
      if user.customer
        subscription = Subscription.find_by(payer: user.customer, payment_method: :direct_transfer)
        SubscriptionBlueprint.render_as_hash(subscription) if subscription
      end
    end
  end
end
