require 'spec_helper'

describe 'Uptime Monitor' do
  # silence puts
  before do
    Uptimer::Monitor.any_instance.stub(:puts)
  end
  it 'should be able to get http response code' do
    stub = stub_request(:get, TEST_URL).to_return(status: 200)
    monitor = Uptimer::Monitor.new(TEST_URL)
    status = monitor.check_status
    stub.should have_been_requested
    status.should eq(200)
  end

  it 'should be able to recognize that site is unreachable' do
    stub = stub_request(:get, TEST_URL).to_timeout
    monitor = Uptimer::Monitor.new(TEST_URL)
    status = monitor.reachable?
    stub.should have_been_made.times(3)
    status.should eq(false)
  end

  it 'should be able to recognize that site is reachable' do
    number_of_tries = 5
    stub = stub_request(:get, TEST_URL)
      .to_return(status: 200).times(number_of_tries)
    monitor = Uptimer::Monitor.new(TEST_URL, number_of_tries)
    status = monitor.reachable?
    stub.should have_been_requested
    status.should eq(true)
  end

  it 'should not consider site unreachable unless it was down for consecutive number of tries' do
    number_of_tries = 10
    stub = stub_request(:get, TEST_URL)
      .to_return(status: 500).times(9).then
      .to_return(status: 200)
    monitor = Uptimer::Monitor.new(TEST_URL, number_of_tries)
    status = monitor.reachable?
    stub.should have_been_made.times(10)
    status.should eq(true)
  end

  it 'should notify user when site is unreachable' do
    number_of_tries = 3
    stub_request(:get, TEST_URL)
      .to_return(status: 500).times(number_of_tries)
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

  it 'should notify user when site becomes reachable' do
    stub_request(:get, TEST_URL)
      .to_return(status: 200)
    monitor = Uptimer::Monitor.new(TEST_URL, 3)
    monitor.email = 'test@test.com'
    monitor.notified = true
    thread = Thread.new do
      monitor.start
    end
    sleep(1)
    thread.kill
    should have_sent_email.to('test@test.com').with_subject("Website #{TEST_URL} is up.")
  end
end
