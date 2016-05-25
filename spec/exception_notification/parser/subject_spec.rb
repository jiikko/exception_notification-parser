require 'spec_helper'

describe ExceptionNotification::Parser::Subject do
  describe 'subject' do
    let(:parsed_subject) { ExceptionNotification::Parser::Subject.new(mail_subject) }

    context 'failure parse' do
      context '[name] nginx 504 のとき' do
        let(:mail_subject) { "[MAIL_ADMIN] nginx 504" }
        it 'be success' do
          expect(parsed_subject.get(:email_prefix)).to eq nil
          expect(parsed_subject.get(:controller_name)).to eq nil
          expect(parsed_subject.get(:error_message)).to eq nil
          expect(parsed_subject.get(:exception_class_name)).to eq nil
          expect {
          parsed_subject.get!(:exception_class_name)
          }.to raise_error(ExceptionNotification::Parser::Error)
        end
      end
    end

    context 'success parse' do
      context '[name] controller#acton (ExceptionClass) のとき' do
        let(:mail_subject) { '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)' }

        it 'be sucess' do
          expect(parsed_subject.to_s).to eq '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)'
          expect(parsed_subject.get(:email_prefix)).to eq '[MAIL_ADMIN]'
          expect(parsed_subject.get(:controller_name)).to eq 'path_to'
          expect(parsed_subject.get(:action_name)).to eq 'create'
          expect(parsed_subject.get(:exception_class_name)).to eq 'ActionController::InvalidAuthenticityToken'
          expect(parsed_subject.get!(:exception_class_name)).to eq 'ActionController::InvalidAuthenticityToken'
          expect(parsed_subject.get(:error_message)).to eq nil
          expect(parsed_subject.get!(:error_message)).to eq nil
        end
      end

      context '[name] (ExceptionClass) のとき' do
        let(:mail_subject) { "[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\"" }
        it 'be sucess' do
          expect(parsed_subject.to_s).to eq "[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\""
          expect(parsed_subject.get(:controller_name)).to be_nil
          expect(parsed_subject.get(:action_name)).to be_nil
          expect(parsed_subject.get(:exception_class_name)).to eq 'Net::IMAP::NoResponseError'
          expect(parsed_subject.get(:error_message)).to eq "\" Authentication failed.\""
        end
      end

      context '[name] controller#acton (ExceptionClass) のとき2' do
        let(:mail_subject) { "[MAIL_ADMIN] anonymous_emails#new (NoMethodError) \"undefined method `expired?' for nil:NilClass\"" }
        it 'be suecess' do
          expect(parsed_subject.get(:controller_name)).to eq 'anonymous_emails'
          expect(parsed_subject.get(:action_name)).to eq 'new'
          expect(parsed_subject.get(:exception_class_name)).to eq 'NoMethodError'
          expect(parsed_subject.get(:error_message)).to eq "\"undefined method `expired?' for nil:NilClass\""
        end
      end

      context '[rails-error] # (ActionController::BadRequest) "ActionController::BadRequest" のとき' do
        let(:mail_subject) { "[rails-error] # (ActionController::BadRequest) \"ActionController::BadRequest\"" }
        it 'be sucess' do
          expect(parsed_subject.get(:controller_name)).to eq ''
          expect(parsed_subject.get(:action_name)).to eq ''
          expect(parsed_subject.get(:exception_class_name)).to eq 'ActionController::BadRequest'
          expect(parsed_subject.get(:error_message)).to eq "\"ActionController::BadRequest\""
        end
      end
    end
  end
end
