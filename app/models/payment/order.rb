class Order
  attr_accessor :id, :payer, :gateway, :payment, :payment_method,
                :offer, :card, :operation, :payment_method_id,
                :payment_method_types, :payment_method_data,
                :payment_method_options

  def initialize(params = {})
    self.id        = params[:id]
    self.payment   = params[:payment]
    self.gateway   = params[:gateway]
    self.card      = params[:card]
    self.operation = params[:operation]

    initialize_payment_related_attributes(params)
    initialize_payment_method_related_attributes(params)
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

  def self.from_pix(payment, operation = nil)
    params = {
      id: payment.id,
      gateway: payment&.offer&.gateway&.to_sym,
      payer: payment&.payer,
      payment:,
      payment_method: payment&.payment_method,
      offer: payment&.offer,
      operation:,
      payment_method_types: ['pix'],
      payment_method_data: { type: 'pix' },
      payment_method_options: { pix: { expires_at: 30.minutes.from_now.to_i } }
    }

    new(params)
  end

  private

  def initialize_payment_related_attributes(params)
    self.payer          = params[:payer]          || payment&.payer
    self.payment_method = params[:payment_method] || payment&.payment_method
    self.offer          = params[:offer]          || payment&.offer
  end

  def initialize_payment_method_related_attributes(params)
    self.payment_method_id = params[:payment_method_id]
    self.payment_method_types = params[:payment_method_types]
    self.payment_method_data = params[:payment_method_data]
    self.payment_method_options = params[:payment_method_options]
  end
end
