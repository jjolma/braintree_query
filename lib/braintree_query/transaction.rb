module BraintreeQuery
  class Transaction < BraintreeQuery::Base
    class << self
      def all(options={})
        find_all options
      end

      def find(txn_id, options={})
        find_all(options.merge(:transaction_id => txn_id)).first
      end

      def find_all(options)
        response_hash = query(options)
        txns = []
        if response_hash
          txn_hashes = response_hash['transaction']

          # handle the single result scenario
          if txn_hashes.is_a?(Hash)
            txn_hashes = [txn_hashes]
          end
          txn_hashes.each do |txn_hash|
            txns << Transaction.new(txn_hash)
          end
        end
        txns
      end
    end
  end
end
