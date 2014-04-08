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
      response = {}
      begin
        response[:code] = Net::HTTP.get_response(uri).code.to_i
        response[:status] = (400..599).include?(response[:code]) ? :failure : :ok
      rescue Timeout::Error
        response[:status] = :failure
        response[:desc] = 'Timeout Error'
      rescue SocketError
        response[:status] = :failure
        response[:desc] = 'Socket Error'
      rescue Errno::ECONNREFUSED
        response[:status] = :failure
        response[:desc] = 'Connection Refused'
      end
      response
    end

    def reachable?
      @number_of_tries.times do
        response = check_status
        puts "Response from #{@url}: #{response[:code]} #{response[:desc]}"
        unless response[:status] == :failure
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
          response = check_status
          if @notified == false
            Uptimer::Notifier.send_mail({ site: @url,
                                        code: "#{response[:code]} #{response[:desc]}",
                                        status: 'down.' }, @email)
            @notified = true
          end
        else
          if @notified == true
            Uptimer::Notifier.send_mail({ site: @url, status: 'up.' }, @email)
            @notified = false
          end
        end
        sleep(5)
      end
    end
  end
end
