require 'rails_helper'

RSpec.describe 'Seed' do
  describe '#load_seed' do
    subject(:run_seed) { Rails.application.load_seed }

    it 'runs without raising error' do
      expect { run_seed }.not_to raise_error
    end

    it 'creates Ribon first configurations' do
      expect { run_seed }.to change(RibonConfig, :count).by(1)
    end

    it 'creates a NonProfit' do
      expect { run_seed }.to change(NonProfit, :count).by(1)
    end

    it 'creates an Article' do
      expect { run_seed }.to change(Article, :count).by(1)
    end

    it 'creates a BalanceHistory' do
      expect { run_seed }.to change(BalanceHistory, :count).by(1)
    end

    it 'creates a Batch' do
      expect { run_seed }.to change(Batch, :count).by(1)
    end

    it 'creates a BigDonor' do
      expect { run_seed }.to change(BigDonor, :count).by(1)
    end

    it 'creates a Cause' do
      expect { run_seed }.to change(Cause, :count).by(1)
    end

    it 'creates the Mumbai Chain' do
      expect { run_seed }.to change(Chain, :count).by(1)
    end

    it 'creates a Donation' do
      expect { run_seed }.to change(Donation, :count).by(1)
    end

    it 'creates a DonationBatch' do
      expect { run_seed }.to change(DonationBatch, :count).by(1)
    end

    it 'creates an IntegrationTask' do
      expect { run_seed }.to change(IntegrationTask, :count).by(1)
    end

    it 'creates an IntegrationWallet' do
      expect { run_seed }.to change(IntegrationWallet, :count).by(1)
    end

    it 'creates an Integration' do
      expect { run_seed }.to change(Integration, :count).by(1)
    end

    it 'creates a NonProfitImpact' do
      expect { run_seed }.to change(NonProfitImpact, :count).by(1)
    end

    it 'creates a NonProfitPool' do
      expect { run_seed }.to change(NonProfitPool, :count).by(1)
    end

    it 'creates a NonProfitWallet' do
      expect { run_seed }.to change(NonProfitWallet, :count).by(1)
    end

    it 'creates a Pool' do
      expect { run_seed }.to change(Pool, :count).by(1)
    end

    it 'creates a Token' do
      expect { run_seed }.to change(Token, :count).by(1)
    end

    it 'creates a User' do
      expect { run_seed }.to change(User, :count).by(1)
    end

    it 'creates UserDonationStats' do
      expect { run_seed }.to change(UserDonationStats, :count).by(1)
    end

    it 'creates a Voucher' do
      expect { run_seed }.to change(Voucher, :count).by(1)
    end
  end
end
