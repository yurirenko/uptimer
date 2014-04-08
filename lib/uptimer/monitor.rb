module Uptimer
  class Monitor
    attr_accessor :reachable, :url, :number_of_tries,
                  :email, :notified

    def initialize(url, number_of_tries = 3)
      @number_of_tries = number_of_tries
      @reachable = true
      @url = url
      @notified = false
    end

    def check_status
      uri = URI(@url)
      begin
        response = Net::HTTP.get_response(uri).code.to_i
      rescue Timeout::Error
        return 'Timeout Error'
      rescue SocketError
        return 'Socket error'
      rescue Errno::ECONNREFUSED
        return 'Connection refused'
      end
      response
    end

    def reachable?
      @number_of_tries.times do
        status = check_status
        puts "Response from #{@url}: #{status}"
        unless status.nil? || (400..599).include?(status) || status.is_a?(String)
          @reachable = true
          return true
        end
      end
      puts "#{@number_of_tries} consecutive tries, #{@url} is unreachable"
      @reachable = false
      false
    end

    def start
      loop do
        reachable?
        if @reachable == false
          code = check_status
          if @notified == false
            Uptimer::Mailer.send_mail({ site: @url, code: code, status: 'down.' }, @email)
            @notified = true
          end
        else
          if @notified == true
            Uptimer::Mailer.send_mail({ site: @url, status: 'up.' }, @email)
            @notified = false
          end
        end
        sleep(5)
      end
    end
  end
end
