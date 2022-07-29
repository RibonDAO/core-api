FactoryBot.define do
  factory :integration_wallet do
    public_key { '0x27e26b8fdc3b84d6c3c9c5b7eb60dcbe2963bdba' }
    encrypted_private_key { 'f10e5b7f78587398999f9ce0d233de46396a1d5891d0048a3f6a9f39898ac3df' }
    private_key_iv { '849346d327c9' }
  end
end
