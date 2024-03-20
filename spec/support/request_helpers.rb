module RequestHelpers
  shared_context 'when making a patron request' do
    let(:headers) do
      { Authorization: "Bearer #{token}" }
    end
    let(:patron) { create(:big_donor) }
    let(:token) { Jwt::Auth::Issuer.call(patron).first }
  end

  shared_context 'when making a user request' do
    let(:headers) do
      { Authorization: "Bearer #{token}" }
    end
    let(:account) { create(:account) }
    let(:token) { Jwt::Auth::Issuer.call(account).first }
  end
end
