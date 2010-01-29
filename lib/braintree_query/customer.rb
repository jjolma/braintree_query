module BraintreeQuery
  class Customer < BraintreeQuery::Base
    class << self
      def all(options={})
        find_all options
      end

      def find(vault_id, options={})
        find_all(options.merge(:customer_vault_id => vault_id)).first
      end

      def find_all(options)
        response_hash = query(options.merge('report_type' => 'customer_vault'))
        customers = []
        if response_hash
          customer_hashes = response_hash['customer_vault']
          customer_hashes = customer_hashes['customer'] if customer_hashes

          # handle the single result scenario
          if customer_hashes.is_a?(Hash)
            customer_hashes = [customer_hashes]
          end
          customer_hashes.each do |customer_hash|
            customers << Customer.new(customer_hash)
          end
        end
        customers
      end
    end
  end
end
