# frozen_string_literal: true

module StubHelpers
  def command_double(klass:, result: nil, errors: {}, failure: false, success: true)
    instance_double(klass.to_s, result:,
                                errors:, failure?: failure, success?: success)
  end

  def mock_command(klass:, result: nil, errors: {}, failure: false, success: true)
    mocked_command = command_double(klass:, result:,
                                    errors:, failure:, success:)
    allow(klass).to receive(:call).and_return(mocked_command)
  end

  def mock_instance(klass:, methods: {}, mock_methods: [])
    mocked_instance = instance_double(klass, methods)
    allow(klass).to receive(:new).and_return(mocked_instance)

    mock_methods.each { |method_name| allow(mocked_instance).to receive(method_name) }
    mocked_instance
  end

  shared_context 'when mocking a request' do
    before do
      VCR.insert_cassette cassette_name
    end

    after do
      VCR.eject_cassette
    end
  end
end
