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
      File.join(ExceptionNotification::Parser.spec_root, 'mail_raw', 'NoMethodError')
    )
    ExceptionNotification::Parser::Struct.new(body: mail_raw)
  end
  let 'struct_from_some_lost_mail' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail_raw', 'NoMethodError_ver_incompalte')
    )
    ExceptionNotification::Parser::Struct.new(body: mail_raw)
  end

  describe '#faild_names?' do
    it 'falseを返すこと' do
      expect(struct_from_some_lost_mail.parse_success?).to eq true
      struct_from_some_lost_mail.test(:environment_request_method)
      expect(struct_from_some_lost_mail.parse_success?).to eq false
      expect(struct_from_some_lost_mail.parse_faild_names).to eq([:environment_request_method])
      expect {
        struct_from_some_lost_mail.get(:environment_request_method)
      }.to raise_error(ExceptionNotification::Parser::Error)
    end
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

  describe 'request' do
    describe '#request_url' do
      it { expect(struct.get(:request_url)).to eq('http://exmple.com/home/path_to') }
    end
    describe '#request_http_method' do
      it { expect(struct.get(:request_http_method)).to eq('POST') }
    end
    describe '#request_ip_address' do
      it { expect(struct.get(:request_ip_address)).to eq('256.183.183.25') }
    end
    describe '#request_timestamp' do
      it { expect(struct.get(:request_timestamp)).to eq(Time.parse '2016-03-27 16:59:28 +0900') }
    end
    describe '#requist_rails_root' do
      it { expect(struct.get(:requist_rails_root)).to eq('/var/www/mail_admin/releases/20160316153334') }
    end
    describe '#requist_parameters' do
      it {
        skip
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
      it { expect(struct.get(:session_id)).to eq('e6832') }
    end
    describe '#session_data' do
      it {
        skip
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
        struct.get(:environment_content_length)
      ).to eq('128') }
    end
    describe '#environment_content_type' do
      it { expect(
        struct.get(:environment_content_type)
      ).to eq('application/x-www-form-urlencoded') }
    end
    describe '#environment_http_host' do
      it { expect(
        struct.get(:environment_http_host)
      ).to eq('exmple.com') }
    end
    describe '#environment_http_user_agent' do
      it { expect(
        struct.get(:environment_http_user_agent)
      ).to eq('Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5') }
    end
    describe '#environment_remote_addr' do
      it { expect(
        struct.get(:environment_remote_addr)
      ).to eq('127.0.0.1') }
    end
    describe '#environment_request_path' do
      it { expect(
        struct.get(:environment_request_path)
      ).to eq('/home/path_to') }
    end
    describe '#environment_request_uri' do
      it { expect(
        struct.get(:environment_request_uri)
      ).to eq('/home/path_to') }
    end
    describe '#environment_request_method' do
      it { expect(
        struct.get(:environment_request_method)
      ).to eq('POST') }
      context 'case2_struct' do
        it { expect(
          case2_struct.get(:environment_request_method)
        ).to eq('GET') }
      end
    end
  end
end
