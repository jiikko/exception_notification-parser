require 'spec_helper'

describe ExceptionNotification::Parser::Struct do
  let 'struct' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail', 'InvalidAuthenticityToken')
    )
    ExceptionNotification::Parser::Struct.new(mail_raw: mail_raw)
  end
  let 'case2_struct' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail', 'NoMethodError')
    )
    ExceptionNotification::Parser::Struct.new(body: mail_raw)
  end
  let 'some_lost_names_struct' do
    mail_raw = File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail', 'NoMethodError_ver_incompalte')
    )
    ExceptionNotification::Parser::Struct.new(body: mail_raw)
  end

  context 'parse some_lost_names_struct' do
    describe '#not_found_names' do
      it '配列を返すこと' do
        expect(some_lost_names_struct.parse_success?).to eq true
        some_lost_names_struct.test(:waiwai_name)
        some_lost_names_struct.test(:waiwai_name)
        some_lost_names_struct.test(:foo_name)
        expect(some_lost_names_struct.not_found_names.size).to eq 2
        expect(some_lost_names_struct.parse_success?).to eq false
        expect(some_lost_names_struct.not_found_names).to match_array([
          :waiwai_name, :foo_name
        ])
      end
    end

    describe 'parse_failure_names' do
      it '配列を返すこと' do
        expect(some_lost_names_struct.parse_success?).to eq true
        some_lost_names_struct.test(:environment_request_method)
        expect(some_lost_names_struct.parse_success?).to eq false
        expect(some_lost_names_struct.parse_failure_names).to eq([:environment_request_method])
        expect(some_lost_names_struct.not_found_names).to eq([])
        expect(
          some_lost_names_struct.get(:environment_request_method)
        ).to eq nil
        expect {
          some_lost_names_struct.get!(:environment_request_method)
        }.to raise_error(ExceptionNotification::Parser::Error)
      end
    end
  end

  describe 'all' do
    context 'case2 struct' do
      it 'be success' do
        expect(case2_struct.get(:environment_request_method)).to eq('GET')
      end
    end
    context 'struct' do
      it 'be success' do
        expect(struct.get(:request_url)).to eq 'http://exmple.com/home/path_to'
        expect(struct.get(:request_http_method)).to eq 'POST'
        expect(struct.get(:request_ip_address)).to eq '256.183.183.25'
        expect(struct.get(:request_timestamp)).to eq(Time.parse '2016-03-27 16:59:28 +0900')
        expect(struct.get(:requist_rails_root)).to eq '/var/www/mail_admin/releases/20160316153334'
        expect(struct.get(:session_id)).to eq 'e6832'
        expect(struct.get(:environment_content_length)).to eq '128'
        expect(struct.get(:environment_content_type)).to eq 'application/x-www-form-urlencoded'
        expect(struct.get(:environment_http_host)).to eq 'exmple.com'
        expect(
          struct.get(:environment_http_user_agent)
        ).to eq('Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5')
        expect(struct.get(:environment_remote_addr)).to eq '127.0.0.1'
        expect(struct.get(:environment_request_path)).to eq '/home/path_to'
        expect(struct.get(:environment_request_uri)).to eq '/home/path_to'
        expect(struct.get(:environment_request_method)).to eq 'POST'
        expect(struct.parse_success?).to eq true
      end
    end
  end
end
