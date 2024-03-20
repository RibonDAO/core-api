class PaymentIntent
  attr_accessor :external_id, :gateway, :operation

  def initialize(params = {})
    self.external_id = params[:external_id]
    self.gateway   = params[:gateway]
    self.operation = params[:operation]
  end

  def self.from(external_id, gateway, operation)
    params = {
      external_id:,
      gateway:,
      operation:
    }

    new(params)
  end
end
