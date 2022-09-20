class CreditCard
  attr_reader :cvv, :number, :name, :expiration_month, :expiration_year

  def initialize(cvv:, number:, name:, expiration_month:, expiration_year:)
    @cvv = cvv
    @number = number
    @name = name
    @expiration_month = expiration_month
    @expiration_year = expiration_year
  end

  def self.from(card)
    params = {
      cvv: card[:cvv],
      number: card[:number],
      name: card[:name],
      expiration_month: card[:expiration_month],
      expiration_year: card[:expiration_year]
    }

    new(params)
  end
end
