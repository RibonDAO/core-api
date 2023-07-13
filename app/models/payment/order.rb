class Order
  attr_accessor :id, :payer, :gateway, :payment, :payment_method,
                :offer, :card, :operation, :payment_method_id

  def initialize(params = {})
    self.id        = params[:id]
    self.payment   = params[:payment]
    self.gateway   = params[:gateway]
    self.card      = params[:card]
    self.operation = params[:operation]
    self.payment_method_id = params[:payment_method_id]

    initialize_payment_related_attributes(params)
  end

  def self.from(payment, card = nil, operation = nil, payment_method_id = nil)
    params = {
      id: payment.id,
      gateway: payment&.offer&.gateway&.to_sym,
      payer: payment&.payer,
      payment:,
      payment_method: payment&.payment_method,
      offer: payment&.offer,
      card:,
      operation:,
      payment_method_id:
    }

    new(params)
  end

  private

  def initialize_payment_related_attributes(params)
    self.payer          = params[:payer]          || payment&.payer
    self.payment_method = params[:payment_method] || payment&.payment_method
    self.offer          = params[:offer]          || payment&.offer
  end
end
