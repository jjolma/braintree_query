require 'helper'

# TODO add this as a gem requirement (at least for test mode)
require 'fakeweb'

class TestBraintreeQuery < Test::Unit::TestCase
  def setup
    # HTTP requests mocked out in respective tests
    FakeWeb.allow_net_connect = false
  end

  def test_find_within_unknown_txn_id
    FakeWeb.register_uri(:post, /.*/, :body => empty_transactions_xml)
    assert_nil BraintreeQuery::Transaction.find(12345)
  end

  def test_find
    FakeWeb.register_uri(:post, /.*/, :body => single_transaction_xml)

    txn_id = 1177101697
    txn = BraintreeQuery::Transaction.find(123)
    assert_not_nil txn
    assert_equal txn_id.to_s, txn.transaction_id
    assert_equal 'Eric', txn.first_name
  end

  def test_all
    FakeWeb.register_uri(:post, /.*/, :body => multiple_transaction_xml)

    txns = BraintreeQuery::Transaction.all
    assert_not_nil txns
    assert_equal 2, txns.size
    assert_equal ['1176380853', '1176380089'].sort, txns.map(&:transaction_id).sort
  end

  def test_handles_credential_error
    FakeWeb.register_uri(:post, /.*/, :body => error_xml)
    assert_raises BraintreeQuery::CredentialError do
      BraintreeQuery::Transaction.all
    end
  end

  def test_handles_generic_error
    FakeWeb.register_uri(:post, /.*/, :body => generic_error_xml)
    assert_raises BraintreeQuery::Error do
      BraintreeQuery::Transaction.all
    end
  end

  # TODO handle the 'action' section of a transaction (can have multiple e.g. if refunded)

  # TODO best way to do integration tests that actually hit the server?
  #    def test_integration_find
  #      FakeWeb.allow_net_connect = true
  #      txn_id = 1177101697
  #      txn = BraintreeQuery::Transaction.find(1177101697, :username => 'testapi', :password => 'password1')
  #      assert_equal txn_id.to_s, txn.transaction_id
  #    end
  #
  #    def test_integration_all_by_date_range
  #      FakeWeb.allow_net_connect = true
  #
  #      # 15 minute window with three transactions
  #      start = ['2010', '01', '20', '15', '00'].join
  #      finish = ['2010', '01', '20', '15', '18'].join
  #      txns = BraintreeQuery::Transaction.all(:username => 'testapi',
  #                                             :password => 'password1',
  #                                             :start_date => start,
  #                                             :end_date => finish)
  #
  #      assert_equal 3, txns.size
  #      assert_equal ["1177097583", "1177098339", "1177099345"].sort, txns.map(&:transaction_id).sort
  #    end
  #
  #    def test_integration_find_refunds
  #      FakeWeb.allow_net_connect = true
  #
  #      # 12 hour window with two refunds
  #      start =  ['2010', '01', '19', '00'].join
  #      finish = ['2010', '01', '19', '12'].join
  #      txns = BraintreeQuery::Transaction.all(:username => 'testapi',
  #                                             :password => 'password1',
  #                                             :start_date => start,
  #                                             :end_date => finish,
  #                                             :action_type => 'refund')
  #      assert_equal 2, txns.size
  #      assert_equal ["1176565207", "1176565239"].sort, txns.map(&:transaction_id).sort
  #    end

  protected
  def empty_transactions_xml
    <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <nm_response>
      </nm_response>
    EOF
  end

  def error_xml
    <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <nm_response>
        <error_response>Invalid Username/Password REFID:201239399</error_response>
      </nm_response>
    EOF
  end

  def generic_error_xml
    <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <nm_response>
        <error_response>Some error we don't explicitely handle</error_response>
      </nm_response>
    EOF
  end

  def single_transaction_xml
    <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <nm_response>
      	<transaction>
      		<transaction_id>1177101697</transaction_id>
      		<platform_id></platform_id>
      		<transaction_type>cc</transaction_type>
      		<condition>pendingsettlement</condition>
      		<order_id></order_id>
      		<authorization_code>123456</authorization_code>
      		<ponumber></ponumber>
      		<order_description></order_description>
      		<first_name>Eric</first_name>
      		<last_name>Cartman</last_name>
      		<address_1></address_1>
      		<address_2></address_2>
      		<company></company>
      		<city></city>
      		<state></state>
      		<postal_code></postal_code>
      		<country></country>
      		<email></email>
      		<phone></phone>
      		<fax></fax>
      		<cell_phone></cell_phone>
      		<customertaxid></customertaxid>
      		<customerid>906770526</customerid>
      		<website></website>
      		<shipping_first_name></shipping_first_name>
      		<shipping_last_name></shipping_last_name>
      		<shipping_address_1></shipping_address_1>
      		<shipping_address_2></shipping_address_2>
      		<shipping_company></shipping_company>
      		<shipping_city></shipping_city>
      		<shipping_state></shipping_state>
      		<shipping_postal_code></shipping_postal_code>
      		<shipping_country></shipping_country>
      		<shipping_email></shipping_email>
      		<shipping_carrier></shipping_carrier>
      		<tracking_number></tracking_number>
      		<shipping_date></shipping_date>
      		<shipping></shipping>
      		<cc_number>4xxxxxxxxxxx1111</cc_number>
      		<cc_hash>f6c609e195d9d4c185dcc8ca662f0180</cc_hash>
      		<cc_exp>0614</cc_exp>
      		<cavv></cavv>
      		<cavv_result></cavv_result>
      		<xid></xid>
      		<avs_response></avs_response>
      		<csc_response></csc_response>
      		<cardholder_auth></cardholder_auth>
      		<check_account></check_account>
      		<check_hash></check_hash>
      		<check_aba></check_aba>
      		<check_name></check_name>
      		<account_holder_type></account_holder_type>
      		<account_type></account_type>
      		<sec_code></sec_code>
      		<processor_id>ccprocessora</processor_id>
      		<tax>0.00</tax>
      		<currency>USD</currency>
      		<cc_bin>411111</cc_bin>
      		<action>
      			<amount>100.00</amount>
      			<action_type>sale</action_type>
      			<date>20100120152810</date>
      			<success>1</success>
      			<ip_address>85.50.70.53</ip_address>
      			<source>api</source>
      			<username>testapi</username>
      			<response_text>SUCCESS</response_text>
      			<batch_id>0</batch_id>
      			<processor_batch_id></processor_batch_id>
      		</action>
      	</transaction>
      </nm_response>
      EOF
  end

  def multiple_transaction_xml
    <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <nm_response>
      <transaction>
        <transaction_id>1176380089</transaction_id>
        <platform_id></platform_id>
        <transaction_type>cc</transaction_type>
        <condition>pendingsettlement</condition>
        <order_id></order_id>
        <authorization_code>123456</authorization_code>
        <ponumber></ponumber>
        <order_description></order_description>
        <first_name></first_name>
        <last_name></last_name>
        <address_1></address_1>
        <address_2></address_2>
        <company></company>
        <city></city>
        <state></state>
        <postal_code></postal_code>
        <country></country>
        <email></email>
        <phone></phone>
        <fax></fax>
        <cell_phone></cell_phone>
        <customertaxid></customertaxid>
        <customerid>1641772517</customerid>
        <website></website>
        <shipping_first_name></shipping_first_name>
        <shipping_last_name></shipping_last_name>
        <shipping_address_1></shipping_address_1>
        <shipping_address_2></shipping_address_2>
        <shipping_company></shipping_company>
        <shipping_city></shipping_city>
        <shipping_state></shipping_state>
        <shipping_postal_code></shipping_postal_code>
        <shipping_country></shipping_country>
        <shipping_email></shipping_email>
        <shipping_carrier></shipping_carrier>
        <tracking_number></tracking_number>
        <shipping_date></shipping_date>
        <shipping></shipping>
        <cc_number>4xxxxxxxxxxx1111</cc_number>
        <cc_hash>f6c609e195d9d4c185dcc8ca662f0180</cc_hash>
        <cc_exp>1010</cc_exp>
        <cavv></cavv>
        <cavv_result></cavv_result>
        <xid></xid>
        <avs_response></avs_response>
        <csc_response></csc_response>
        <cardholder_auth></cardholder_auth>
        <check_account></check_account>
        <check_hash></check_hash>
        <check_aba></check_aba>
        <check_name></check_name>
        <account_holder_type></account_holder_type>
        <account_type></account_type>
        <sec_code></sec_code>
        <processor_id>ccprocessora</processor_id>
        <tax>0.00</tax>
        <currency>USD</currency>
        <cc_bin>411111</cc_bin>
        <action>
          <amount>1476.00</amount>
          <action_type>sale</action_type>
          <date>20100118171150</date>
          <success>1</success>
          <ip_address>208.86.238.43</ip_address>
          <source>api</source>
          <username>testapi</username>
          <response_text>SUCCESS</response_text>
          <batch_id>0</batch_id>
          <processor_batch_id></processor_batch_id>
        </action>
      </transaction>
      <transaction>
        <transaction_id>1176380853</transaction_id>
        <platform_id></platform_id>
        <transaction_type>cc</transaction_type>
        <condition>pending</condition>
        <order_id>b08209bc-0454-11df-b21a-0800270ecde6</order_id>
        <authorization_code>123456</authorization_code>
        <ponumber></ponumber>
        <order_description></order_description>
        <first_name></first_name>
        <last_name></last_name>
        <address_1></address_1>
        <address_2></address_2>
        <company></company>
        <city></city>
        <state></state>
        <postal_code>12344</postal_code>
        <country></country>
        <email></email>
        <phone></phone>
        <fax></fax>
        <cell_phone></cell_phone>
        <customertaxid></customertaxid>
        <customerid>279963267</customerid>
        <website></website>
        <shipping_first_name></shipping_first_name>
        <shipping_last_name></shipping_last_name>
        <shipping_address_1></shipping_address_1>
        <shipping_address_2></shipping_address_2>
        <shipping_company></shipping_company>
        <shipping_city></shipping_city>
        <shipping_state></shipping_state>
        <shipping_postal_code></shipping_postal_code>
        <shipping_country></shipping_country>
        <shipping_email></shipping_email>
        <shipping_carrier></shipping_carrier>
        <tracking_number></tracking_number>
        <shipping_date></shipping_date>
        <shipping></shipping>
        <cc_number>4xxxxxxxxxxx1111</cc_number>
        <cc_hash>f6c609e195d9d4c185dcc8ca662f0180</cc_hash>
        <cc_exp>0621</cc_exp>
        <cavv></cavv>
        <cavv_result></cavv_result>
        <xid></xid>
        <avs_response>N</avs_response>
        <csc_response>M</csc_response>
        <cardholder_auth></cardholder_auth>
        <check_account></check_account>
        <check_hash></check_hash>
        <check_aba></check_aba>
        <check_name></check_name>
        <account_holder_type></account_holder_type>
        <account_type></account_type>
        <sec_code></sec_code>
        <processor_id>ccprocessora</processor_id>
        <tax>0.00</tax>
        <currency>USD</currency>
        <cc_bin>411111</cc_bin>
        <product>
          <sku>Pages50</sku>
          <quantity></quantity>
          <description></description>
          <amount></amount>
        </product>
        <action>
          <amount>1.00</amount>
          <action_type>auth</action_type>
          <date>20100118171243</date>
          <success>1</success>
          <ip_address>74.73.145.54</ip_address>
          <source>api</source>
          <username>BraintreeTest</username>
          <response_text>SUCCESS</response_text>
          <batch_id>0</batch_id>
          <processor_batch_id></processor_batch_id>
        </action>
      </transaction>
    </nm_response>
    EOF
  end
end


