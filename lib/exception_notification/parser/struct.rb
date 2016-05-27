module ExceptionNotification::Parser
  class Struct
    attr_reader :body, :parse_failure_names, :not_found_names

    NAME_TABLE = {
      # body
      request_url: 'URL',
      request_http_method: 'HTTP Method',
      request_ip_address: 'IP address',
      request_timestamp: 'Timestamp',
      requist_rails_root: 'Rails root',
      session_id: 'session id',
      environment_content_length: 'CONTENT_LENGTH',
      environment_content_type: 'CONTENT_TYPE',
      environment_http_host: 'HTTP_HOST',
      environment_http_user_agent: 'HTTP_USER_AGENT',
      environment_remote_addr: 'REMOTE_ADDR',
      environment_request_path: 'REQUEST_PATH',
      environment_request_uri: 'REQUEST_URI',
      environment_request_method: 'REQUEST_METHOD',
    }

    def initialize(body: nil, mail_raw: nil, subject: nil)
      mail = nil
      @body =
        if mail_raw
          mail = Mail.new(mail_raw)
          mail.body.decoded.toutf8
        else
          body
      end
      @subject = subject || mail && mail.subject
      @parse_failure_names = Set.new
      @not_found_names = Set.new
    end

    def subject
      @subject_instance ||= Subject.new(@subject)
    end

    def parse_failure_names
      @parse_failure_names.to_a
    end

    def not_found_names
      @not_found_names.to_a
    end

    def parse_success?
      @parse_failure_names.empty? && @not_found_names.empty?
    end

    def test(name)
      if exists?(NAME_TABLE[name] || name)
        value = find_value(name, throw_exception: false)
        return (value && true) || ((@parse_failure_names << name) && false)
      else
        @not_found_names << name
        return false
      end
    end

    def has_subject?
      !!@subject
    end

    def get(name)
      test(name)
      find_value(name, throw_exception: false)
    end

    def get!(name)
      find_value(name, throw_exception: true)
    end

    private

    def exists?(name)
      name = name.to_s unless name.is_a?(String)
      @body.include?(name)
    end


    def find_value(name, throw_exception: true)
      if !NAME_TABLE.key?(name) && throw_exception
        return raise('not found name')
      end
      name_to_s = NAME_TABLE[name].to_s
      if exists?(name_to_s)
        find(/#{name_to_s} *: "?(.+?)"?$/, throw_exception: throw_exception)
      end
    end

    def find(regexp, throw_exception: )
      @body =~ regexp
      $1 || (throw_exception ? raise(ExceptionNotification::Parser::Error, 'parse failed') : nil)
    end
  end
end
