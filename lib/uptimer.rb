require 'uptimer/version'
require 'uptimer/mailer'
require 'uptimer/monitor'
require 'net/http'
require 'mail'

module Uptimer
  Mail.defaults do
    delivery_method :smtp, {
      address: 'smtp.gmail.com',
      port: '587',
      user_name: 'ruby.uptimereporter@gmail.com',
      password: 'rubyuptimereporter',
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
end
