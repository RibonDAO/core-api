class ApplicationCommand
  protected

  def with_exception_handle
    yield
  rescue StandardError => e
    errors.add(:message, e.message)
  end
end
