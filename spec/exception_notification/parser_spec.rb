require 'spec_helper'

describe ExceptionNotification::Parser do
  let 'mail_raw' do
    File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail', 'InvalidAuthenticityToken')
    )
  end

  it 'has a version number' do
    expect(ExceptionNotification::Parser::VERSION).not_to be nil
  end

  describe '.parse' do
    it '#request_url をもつこと' do
      struct = ExceptionNotification::Parser.parse(mail_raw: mail_raw)
      subject = struct.subject
      expect(!!struct.get(:request_url)).to eq true
      expect(subject.get(:email_prefix)).to eq '[MAIL_ADMIN]'
      expect(subject.get(:error_message)).to eq nil
      expect(subject.get!(:error_message)).to eq nil
      expect(subject.get(:controller_name)).to eq 'path_to'
    end

    context 'subject 引数がblank' do
      it 'be success' do
        expect(
          ExceptionNotification::Parser.parse(body: '').has_subject?
        ).to eq false
      end
    end
  end
end
