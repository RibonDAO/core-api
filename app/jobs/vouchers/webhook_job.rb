module Vouchers
  class WebhookJob < ApplicationJob
    queue_as :default

    def perform(voucher)
      response = Request::ApiRequest.post(voucher.integration.webhook_url,
                                          body: VoucherBlueprint.render(voucher))

      raise Exceptions::VoucherWebhookError, 'webhook failed' unless response.ok?
    end
  end
end
