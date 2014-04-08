# Uptimer


## Installation

  `git clone https://github.com/yuri-g/uptimer.git`

  `cd uptimer`

  `bundle`

  Change the `notifier_email` and `notifier_password` in `config/config.yml`
to use different mail account to notify user. Also, change the `nexmo_key`
and `nexmo_secret` if you have a Nexmo account. 

  And then:

  `rake install`

## Usage

  `uptimer <website url> <number of tries before consider site down>
<user email> [phone number]`

  For example: 

  `uptimer http://google.com 3 mail@mail.com`
  
  Or:

  `uptimer http://google.com 3 mail@mail.com 9999999`

  Phone number is optional.
