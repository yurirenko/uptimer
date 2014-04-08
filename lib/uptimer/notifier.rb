module Uptimer
  class Notifier
    class << self
      attr_accessor :nexmo_client

      def send_mail(message, address)
        message_body = message[:code].nil? ? "It's up again!" : "Error code: #{message[:code]}"
        mail = Mail.new do
          from      'ruby.uptimereporter@gmail.com'
          to        address
          subject   "Website #{message[:site]} is #{message[:status]}"
          body      message_body
        end
        mail.deliver!
      end

      def send_sms(message, number)
        @nexmo_client.send_message(to: number, from: 'rbuptimemonitor', text: message)
      end
    end
  end
end
