$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('spec/mail_raw', __FILE__)
require 'exception_notification/parser'
require 'pry'

module ExceptionNotification::Parser
  def self.spec_root
    File.expand_path('..', __FILE__)
  end
end
