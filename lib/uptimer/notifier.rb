module Uptimer
  class Notifier
    def self.send_mail(message, address)
      message_body = message[:code].nil? ? "It's up again!" : "Error code: #{message[:code]}"
      mail = Mail.new do
        from      'ruby.uptimereporter@gmail.com'
        to        address
        subject   "Website #{message[:site]} is #{message[:status]}"
        body      message_body
      end
      mail.deliver!
    end
  end
end
