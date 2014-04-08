require 'uptimer/version'
require 'uptimer/notifier'
require 'uptimer/monitor'
require 'net/http'
require 'nexmo'
require 'mail'
require 'yaml'

module Uptimer
  conf = YAML.load_file(File.join(File.dirname(__FILE__), '../config/config.yml'))
  Notifier.nexmo_client = Nexmo::Client.new(conf['nexmo_key'], conf['nexmo_secret'])
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
