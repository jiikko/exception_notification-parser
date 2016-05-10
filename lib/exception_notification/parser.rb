require 'time'
require 'mail'
require 'kconv'
require "exception_notification/parser/version"
require "exception_notification/parser/struct"
require "exception_notification/parser/subject"

module ExceptionNotification
  module Parser
    class Error < StandardError; end

    def self.parse(body: nil, mail_raw: nil, subject: nil)
      Struct.new(body: body, mail_raw: mail_raw, subject: subject)
    end
  end
end
