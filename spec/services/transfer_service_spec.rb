require 'rails_helper'

RSpec.describe TransferService do
  describe '.call' do
    let!(:sender) { Cat.create!(name: 'SpecSender', treats_balance: 100) }
    let!(:recipient) { Cat.create!(name: 'SpecRecipient', treats_balance: 50) }

    it 'moves treats and creates a Transfer on success' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: recipient.id,
        amount: 5
      )

      expect(result).to be_success
      expect(result.transfer).to be_present
      expect(result.transfer.sender_id).to eq(sender.id)
      expect(result.transfer.recipient_id).to eq(recipient.id)
      expect(result.transfer.amount).to eq(5)
      expect(sender.reload.treats_balance).to eq(95)
      expect(recipient.reload.treats_balance).to eq(55)
      expect(Transfer.count).to eq(1)
    end

    it 'rejects insufficient balance without changing balances or creating a Transfer' do
      sender.update!(treats_balance: 10)
      recipient.update!(treats_balance: 50)

      result = described_class.call(
        sender_id: sender.id,
        recipient_id: recipient.id,
        amount: 50
      )

      expect(result).to be_failure
      expect(result.code).to eq(:insufficient_funds)
      expect(sender.reload.treats_balance).to eq(10)
      expect(recipient.reload.treats_balance).to eq(50)
      expect(Transfer.count).to eq(0)
    end

    it 'rejects zero amount' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: recipient.id,
        amount: 0
      )

      expect(result).to be_failure
      expect(result.code).to eq(:invalid_amount)
      expect(sender.reload.treats_balance).to eq(100)
      expect(recipient.reload.treats_balance).to eq(50)
      expect(Transfer.count).to eq(0)
    end

    it 'rejects negative amount' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: recipient.id,
        amount: -1
      )

      expect(result).to be_failure
      expect(result.code).to eq(:invalid_amount)
      expect(Transfer.count).to eq(0)
    end

    it 'rejects non-integer amount' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: recipient.id,
        amount: 1.5
      )

      expect(result).to be_failure
      expect(result.code).to eq(:invalid_amount)
      expect(Transfer.count).to eq(0)
    end

    it 'rejects self-transfer' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: sender.id,
        amount: 1
      )

      expect(result).to be_failure
      expect(result.code).to eq(:same_cat)
      expect(Transfer.count).to eq(0)
    end

    it 'rejects when a cat is missing' do
      result = described_class.call(
        sender_id: sender.id,
        recipient_id: 0,
        amount: 1
      )

      expect(result).to be_failure
      expect(result.code).to eq(:not_found)
      expect(Transfer.count).to eq(0)
    end
  end

  describe '.call concurrent transfers on the same sender' do
    self.use_transactional_tests = false

    let!(:sender) { Cat.create!(name: 'ConcurrentSender', treats_balance: 10) }
    let!(:recipient_a) { Cat.create!(name: 'ConcurrentRecipientA', treats_balance: 0) }
    let!(:recipient_b) { Cat.create!(name: 'ConcurrentRecipientB', treats_balance: 0) }

    after do
      Transfer.delete_all
      Cat.delete_all
    end

    it 'allows only one of two competing full-balance transfers' do
      results = [nil, nil]

      threads = [
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            results[0] = described_class.call(
              sender_id: sender.id,
              recipient_id: recipient_a.id,
              amount: 10
            )
          end
        end,
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            results[1] = described_class.call(
              sender_id: sender.id,
              recipient_id: recipient_b.id,
              amount: 10
            )
          end
        end
      ]
      threads.each(&:join)

      expect(results.count(&:success?)).to eq(1)
      expect(results.count(&:failure?)).to eq(1)
      expect(results.find(&:failure?).code).to eq(:insufficient_funds)
      expect(sender.reload.treats_balance).to eq(0)
      expect(Transfer.count).to eq(1)
      expect([recipient_a.reload.treats_balance, recipient_b.reload.treats_balance]).to contain_exactly(10, 0)
    end
  end
end
