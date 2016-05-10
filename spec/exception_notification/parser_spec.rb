require 'spec_helper'

describe ExceptionNotification::Parser do
  let 'mail_raw' do
    File.read(
      File.join(ExceptionNotification::Parser.spec_root, 'mail_raw', 'InvalidAuthenticityToken')
    )
  end

  it 'has a version number' do
    expect(ExceptionNotification::Parser::VERSION).not_to be nil
  end

  describe '.parse' do
    it '#request_url をもつこと' do
      expect(
        ExceptionNotification::Parser.parse(mail_raw: mail_raw).respond_to?(:request_url)
      ).to eq true
    end

    context 'subject 引数がblank' do
      it 'be success' do
        expect(
          ExceptionNotification::Parser.parse(body: '').has_subject?
        ).to eq false
      end
    end

    context 'parse に失敗するとき' do
      it 'catch exception' do
        expect {
          ExceptionNotification::Parser.parse(mail_raw: 'iiiiiiiii').request_url
        }.to raise_error(ExceptionNotification::Parser::Error)
      end
    end
  end
end
