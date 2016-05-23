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
      expect(
        !!ExceptionNotification::Parser.parse(mail_raw: mail_raw).get(:request_url)
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
        body = File.read(
          File.join(ExceptionNotification::Parser.spec_root, 'mail', 'NoMethodError_ver_incompalte')
        )
        expect(
          ExceptionNotification::Parser.parse(body: body).get(:request_url)
        ).to eq false
      end
    end
  end
end
