require 'spec_helper'

describe 'Uptime Monitor' do
  before(:each) do
    Uptimer::Notifier.any_instance.stub(:puts)
    Uptimer::Monitor.any_instance.stub(:puts)
    @base_stub = stub_request(:get, TEST_URL)
    @monitor = Uptimer::Monitor.new(TEST_URL)
  end

  it 'should be able to get http response code' do
    stub = @base_stub.to_return(status: 200)
    status = @monitor.check_status
    stub.should have_been_requested
    status[:code].should eq(200)
  end

  it 'should be able to recognize that site is unreachable' do
    stub = @base_stub.to_timeout
    status = @monitor.reachable?
    stub.should have_been_made.times(3)
    status.should eq(false)
  end

  it 'should be able to recognize that site is reachable' do
    number_of_tries = 5
    stub = @base_stub.to_return(status: 200).times(number_of_tries)
    monitor = Uptimer::Monitor.new(TEST_URL, number_of_tries)
    status = monitor.reachable?
    stub.should have_been_requested
    status.should eq(true)
  end

  it 'should not consider site unreachable unless it was down for consecutive number of tries' do
    number_of_tries = 10
    stub = @base_stub.to_return(status: 500).times(9).then
                     .to_return(status: 200)
    monitor = Uptimer::Monitor.new(TEST_URL, number_of_tries)
    status = monitor.reachable?
    stub.should have_been_made.times(10)
    status.should eq(true)
  end

  it 'should notify user via email when site is unreachable' do
    number_of_tries = 3
    @base_stub.to_return(status: 500).times(number_of_tries)
    monitor = Uptimer::Monitor.new(TEST_URL, number_of_tries)
    monitor.email = 'test@test.com'
    thread = Thread.new do
      monitor.start
    end
    sleep(1)
    thread.kill
    should have_sent_email.to('test@test.com')
    Mail::TestMailer.deliveries.clear
  end

  it 'should notify user via email when site becomes reachable' do
    @base_stub.to_return(status: 200)
    @monitor.email = 'test@test.com'
    @monitor.notified = true
    thread = Thread.new do
      @monitor.start
    end
    sleep(1)
    thread.kill
    should have_sent_email.to('test@test.com').with_subject("Website #{TEST_URL} is up.")
  end

  describe 'sms notifier' do

    before(:each) do
      @monitor.number = 999999
      @monitor.email = 'test@test.com'
      Uptimer::Notifier.nexmo_client = Nexmo::Client.new('test', 'test')
      @stub_sms = stub_request(:post, 'https://rest.nexmo.com/sms/json').with(JSON_OBJECT)
        .to_return(status: 200, body: 'json:json')
    end

    it 'should notify user with sms when site is unreachable' do
      number_of_tries = 3
      @base_stub.to_return(status: 500).times(number_of_tries)
      thread = Thread.new do
        @monitor.start
      end
      sleep(1)
      thread.kill
      @stub_sms.should have_been_requested
    end

    it 'should notify user with sms when site becomes reachable' do
      @base_stub.to_return(status: 200)
      @monitor.notified = true
      thread = Thread.new do
        @monitor.start
      end
      sleep(1)
      thread.kill
      @stub_sms.should have_been_requested
    end
  end
end
