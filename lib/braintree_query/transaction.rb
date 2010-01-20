require 'uri'
require 'net/https'
require 'xmlsimple'
require 'ostruct'

module BraintreeQuery
  class Transaction < OpenStruct
    BASE_URL = "https://secure.braintreepaymentgateway.com/api/query.php"
    class << self
      def all(options={})
        find_all options
      end

      def find(txn_id, options={})
        find_all(options.merge(:transaction_id => txn_id)).first
      end

      def find_all(options)
        query = options.map { |k,v| "#{k}=#{v}" }.join('&')
        full_url = [BASE_URL, query].join '?'

        uri = URI.parse(full_url)
        server = Net::HTTP.new uri.host, uri.port
        server.use_ssl = uri.scheme == 'https'
        server.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = server.post BASE_URL, query
        response_hash = XmlSimple.xml_in(response.body, { 'NormaliseSpace' => 2 })
        response_hash = massage(response_hash)

        txns = []
        if response_hash
          if err_msg = response_hash['error_response']
            if err_msg =~ /Invalid Username/
              raise BraintreeQuery::CredentialError, err_msg
            else
              raise BraintreeQuery::Error, err_msg
            end
          end
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

      # stolen and trimmed from rails' Hash.from_xml
      def massage(value)
        case value.class.to_s
        when 'Hash'
          if value.size == 0
            nil
          else
            xml_value = value.inject({}) do |h,(k,v)|
              h[k] = massage(v)
              h
            end
          end
        when 'Array'
          value.map! { |i| massage(i) }
          case value.length
          when 0 then nil
          when 1 then value.first
          else value
          end
        when 'String'
          value
        else
          raise "can't massage #{value.class.name} - #{value.inspect}"
        end
      end

    end
  end
end
