require 'ostruct'
require 'uri'
require 'net/https'
require 'xmlsimple'

module BraintreeQuery
  class Base < OpenStruct
    BASE_URL = "https://secure.braintreepaymentgateway.com/api/query.php"

    #
    # Issue a query against Braintree's query API
    #
    # Returns a hash of the response
    #
    def self.query(options)
      raise ArgumentError, "username required" unless options[:username]
      raise ArgumentError, "password required" unless options[:password]

      query = options.map { |k,v| "#{k}=#{v}" }.join('&')
      full_url = [BASE_URL, query].join '?'

      uri = URI.parse(full_url)
      server = Net::HTTP.new uri.host, uri.port
      server.use_ssl = uri.scheme == 'https'
      server.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = server.post BASE_URL, query
      response_hash = XmlSimple.xml_in(response.body, { 'NormaliseSpace' => 2 })
      response_hash = massage(response_hash)

      if response_hash && err_msg = response_hash['error_response']
        if err_msg =~ /Invalid Username/
          raise BraintreeQuery::CredentialError, err_msg
        else
          raise BraintreeQuery::Error, err_msg
        end
      end
      response_hash
    end

    private

    # massage the hash generated from XmlSimple into something more usable
    # stolen and trimmed from rails' Hash.from_xml
    def self.massage(value)
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
