module Currency
  module Helpers
    CURRENCIES = Money::Currency.stringified_keys

    CURRENCIES.each do |currency|
      define_method :"convert_to_#{currency}" do |args|
        new(from: args[:from], value: args[:value], to: currency).convert
      end
      CURRENCIES.each do |currency_from|
        next if currency.eql?(currency_from)

        define_method :"convert_from_#{currency_from}_to_#{currency}" do |value|
          new(from: currency_from, value:, to: currency).convert
        end
      end
    end
  end
end
