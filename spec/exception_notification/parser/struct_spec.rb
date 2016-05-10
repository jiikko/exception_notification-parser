require 'spec_helper'

describe ExceptionNotification::Parser::Struct do
  let 'struct' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail_raw', 'InvalidAuthenticityToken')
    )
    ExceptionNotification::Parser::Struct.new(mail_raw: mail_raw)
  end
  let 'case2_struct' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail_raw', 'InvalidAuthenticityToken')
    )
    ExceptionNotification::Parser::Struct.new(mail_raw: mail_raw)
  end

  describe 'subject' do
    let(:parsed_subject) { ExceptionNotification::Parser::Subject.new(subject) }

    context '[name] controller#acton (ExceptionClass) のとき' do
      let(:subject) { '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)' }

      describe '#to_s' do
        it {
          expect(parsed_subject.to_s).to eq '[MAIL_ADMIN] path_to#create (ActionController::InvalidAuthenticityToken)'
        }
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
    end

    context '[name] (ExceptionClass) のとき' do
      let(:subject) { '[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\"' }
      describe '#to_s' do
        it {
          expect(parsed_subject.to_s).to eq '[MAIL_ADMIN] (Net::IMAP::NoResponseError) \" Authentication failed.\"'
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
    end
  end

  describe 'request' do
    describe '#request_url' do
      it { expect(struct.request_url).to eq('http://exmple.com/home/path_to') }
    end
    describe '#request_http_method' do
      it { expect(struct.request_http_method).to eq('POST') }
    end
    describe '#request_ip_address' do
      it { expect(struct.request_ip_address).to eq('256.183.183.25') }
    end
    describe '#request_timestamp' do
      it { expect(struct.request_timestamp).to eq(Time.parse '2016-03-27 16:59:28 +0900') }
    end
    describe '#requist_rails_root' do
      it { expect(struct.requist_rails_root).to eq('/var/www/mail_admin/releases/20160316153334') }
    end
    describe '#requist_parameters' do
      it {
        expect(struct.requist_parameters).to eq({
          "_method"=>"post",
          "authenticity_token"=>"FPDPElLHYhLSEq5uA8ZehbvekpYpYXFjRFN5Y8CW4M6LrLGglrnX7/+8NNoulXANIJCsYChvfd1EpwUdIY2RJA==",
          "controller"=>"home/path_to",
          "action"=>"create"
        })
      }
    end
  end

  describe 'session' do
    describe '#session_id' do
      it { expect(struct.session_id).to eq('e6832') }
    end
    describe '#session_data' do
      it {
        expect(
          struct.session_data
        ).to eq({
          "session_id" =>  "e6832",
          "_csrf_token" => "HlnWIrPw/RWzI/DWEbMc61UB9s2ce7GmXwV6flNgdZI="
        })
      }
    end
  end

  describe 'environment' do
    describe '#environment_content_length' do
      it { expect(
        struct.environment_content_length
      ).to eq(128) }
    end
    describe '#environment_content_type' do
      it { expect(
        struct.environment_content_type
      ).to eq('application/x-www-form-urlencoded') }
    end
    describe '#environment_http_host' do
      it { expect(
        struct.environment_http_host
      ).to eq('exmple.com') }
    end
    describe '#environment_http_user_agent' do
      it { expect(
        struct.environment_http_user_agent
      ).to eq('Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5') }
    end
    describe '#environment_remote_addr' do
      it { expect(
        struct.environment_remote_addr
      ).to eq('127.0.0.1') }
    end
    describe '#environment_request_path' do
      it { expect(
        struct.environment_request_path
      ).to eq('/home/path_to') }
    end
    describe '#environment_request_uri' do
      it { expect(
        struct.environment_request_uri
      ).to eq('/home/path_to') }
    end
    describe '#environment_request_method' do
      it { expect(
        struct.environment_request_method
      ).to eq('POST') }
    end
  end
end
