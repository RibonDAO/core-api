module Vouchers
  class WebhookJob < ApplicationJob
    queue_as :default

    def perform(voucher, event)
      response = Request::ApiRequest.post(voucher.integration.webhook_url,
                                          body: {
                                            voucher: VoucherBlueprint.render(voucher),
                                            event:
                                          })

      raise Exceptions::VoucherWebhookError, 'webhook failed' unless response.ok?
    end
  end
end
