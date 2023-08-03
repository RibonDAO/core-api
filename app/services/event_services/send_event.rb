module EventServices
  class SendEvent
    attr_reader :event, :user

    def initialize(user:, event:)
      @user = user
      @event = event
    end

    def call
      return unless user.present?

      Crm::Customer::Track.new.send_event(user, event)
    end
  end
end