require 'uptimer/version'
require 'uptimer/mailer'
require 'uptimer/monitor'
require 'net/http'
require 'mail'
require 'yaml'

module Uptimer
  conf = YAML.load_file(File.join(File.dirname(__FILE__), "../config/config.yml"))
  Mail.defaults do
    delivery_method :smtp, {
      address: 'smtp.gmail.com',
      port: '587',
      user_name: conf['notifier_email'],
      password: conf['notifier_password'],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
end
