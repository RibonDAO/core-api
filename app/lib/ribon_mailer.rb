class RibonMailer
  include SendGrid

  attr_reader :client

  def initialize
    @client = SendGrid::API.new(api_key: RibonCoreApi.config[:mailer][:api_key]).client
  end

  def send(data)
    client.mail._('send').post(request_body: data)
  end
end
