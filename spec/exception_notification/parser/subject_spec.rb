require 'spec_helper'

describe ExceptionNotification::Parser::Subject do
  describe 'subject' do
    let(:parsed_subject) { ExceptionNotification::Parser::Subject.new(subject) }

    context '[name] controller#acton (ExceptionClass) のとき' do
      let(:subject) { '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)' }

      describe '#to_s' do
        it {
          expect(parsed_subject.to_s).to eq '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)'
        }
      end
      describe '#email_prefix' do
        it { expect(parsed_subject.email_prefix).to eq '[MAIL_ADMIN]' }
      end
      describe '#controller_name' do
        it { expect(parsed_subject.controller_name).to eq 'path_to' }
      end
      describe '#action_name' do
        it { expect(parsed_subject.action_name).to eq 'create' }
      end
      describe '#error_class_name' do
        it { expect(parsed_subject.exception_class_name).to eq 'ActionController::InvalidAuthenticityToken' }
      end
      describe '#error_message' do
        it { expect(parsed_subject.error_message).to eq nil }
      end
    end

    context '[name] (ExceptionClass) のとき' do
      let(:subject) { "[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\"" }
      describe '#to_s' do
        it {
          expect(parsed_subject.to_s).to eq "[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\""
        }
      end
      describe '#controller_name' do
        it { expect(parsed_subject.controller_name).to be_nil }
      end
      describe '#action_name' do
        it { expect(parsed_subject.action_name).to be_nil }
      end
      describe '#error_class_name' do
        it { expect(parsed_subject.exception_class_name).to eq 'Net::IMAP::NoResponseError' }
      end
      describe '#error_message' do
        it { expect(parsed_subject.error_message).to eq "\" Authentication failed.\"" }
      end
    end

    context '[name] controller#acton (ExceptionClass) のとき2' do
      let(:subject) { "[MAIL_ADMIN] anonymous_emails#new (NoMethodError) \"undefined method `expired?' for nil:NilClass\"" }
      describe '#controller_name' do
        it { expect(parsed_subject.controller_name).to eq 'anonymous_emails' }
      end
      describe '#action_name' do
        it { expect(parsed_subject.action_name).to eq 'new' }
      end
      describe '#error_class_name' do
        it { expect(parsed_subject.exception_class_name).to eq 'NoMethodError' }
      end
      describe '#error_message' do
        it { expect(parsed_subject.error_message).to eq "\"undefined method `expired?' for nil:NilClass\"" }
      end
    end

    context '[rails-error] # (ActionController::BadRequest) "ActionController::BadRequest" のとき' do
      let(:subject) { "[rails-error] # (ActionController::BadRequest) \"ActionController::BadRequest\"" }
      describe '#controller_name' do
        it { expect(parsed_subject.controller_name).to eq '' }
      end
      describe '#action_name' do
        it { expect(parsed_subject.action_name).to eq '' }
      end
      describe '#error_class_name' do
        it { expect(parsed_subject.exception_class_name).to eq 'ActionController::BadRequest' }
      end
      describe '#error_message' do
        it { expect(parsed_subject.error_message).to eq "\"ActionController::BadRequest\"" }
      end
    end
  end
end
