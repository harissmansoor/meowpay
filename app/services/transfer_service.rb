class TransferService
  class Result
    attr_reader :transfer, :code, :message

    def initialize(success:, transfer: nil, code: nil, message: nil)
      @success = success
      @transfer = transfer
      @code = code
      @message = message
    end

    def success?
      @success
    end

    def failure?
      !success?
    end
  end

  def self.call(sender_id:, recipient_id:, amount:)
    new(sender_id:, recipient_id:, amount:).call
  end

  def initialize(sender_id:, recipient_id:, amount:)
    @sender_id = sender_id
    @recipient_id = recipient_id
    @amount = amount
  end

  def call
    parsed_amount = parse_amount
    return failure(:invalid_amount, 'Amount must be a positive integer') if parsed_amount.nil?

    return failure(:same_cat, 'Sender and recipient must be different cats') if @sender_id.to_i == @recipient_id.to_i

    result = nil

    Cat.transaction do
      cats = Cat.lock.where(id: [@sender_id, @recipient_id]).order(:id).index_by(&:id)
      sender = cats[@sender_id.to_i]
      recipient = cats[@recipient_id.to_i]

      if sender.nil? || recipient.nil?
        result = failure(:not_found, 'Sender or recipient not found')
        raise ActiveRecord::Rollback
      end

      if sender.treats_balance < parsed_amount
        result = failure(:insufficient_funds, 'Insufficient treats')
        raise ActiveRecord::Rollback
      end

      sender.treats_balance -= parsed_amount
      recipient.treats_balance += parsed_amount
      sender.save!
      recipient.save!

      transfer = Transfer.create!(
        sender: sender,
        recipient: recipient,
        amount: parsed_amount
      )

      result = Result.new(success: true, transfer: transfer)
    end

    result
  end

  private

  def parse_amount
    return @amount if @amount.is_a?(Integer) && @amount > 0

    if @amount.is_a?(String) && /\A[1-9]\d*\z/.match?(@amount)
      return @amount.to_i
    end

    nil
  end

  def failure(code, message)
    Result.new(success: false, code: code, message: message)
  end
end
