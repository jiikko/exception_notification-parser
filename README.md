# ExceptionNotification::Parser

https://rubygems.org/gems/exception_notification outputed mail parser.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exception_notification-parser'
```

And then execute:

    $ bundle

## Usage

```ruby
mail_raw = File.read('./mail') # body with header

# case 1
struct = ExceptionNotification::Parser.parse(mail_raw: mail_raw)

# case 2
mail = Mail.new(mail_raw)
body = mail.body.decoded.toutf8
struct = ExceptionNotification::Parser.parse(body: body, subject: mail.suject)
```

### accessible list
```
subject.exception_class_name
subject.action_name
subject.controller

request_url
request_http_method
request_ip_address
request_timestamp
requist_rails_root
requist_parameters # hash
session_id
session_data # hash
environment_content_length
environment_content_type
environment_http_host
environment_http_user_agent
environment_remote_addr
environment_request_path
environment_request_uri
environment_request_method
```
