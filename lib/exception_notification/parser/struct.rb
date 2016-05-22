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
      environment_content_length: :CONTENT_LENGTH,
      environment_content_type: :CONTENT_TYPE,
      environment_http_host: 'HTTP_HOST',
      environment_http_user_agent: 'HTTP_USER_AGENT',
      environment_remote_addr: 'REMOTE_ADDR',
      environment_request_path: 'REQUEST_PATH',
      environment_request_uri: 'REQUEST_URI',
      environment_request_method: 'REQUEST_METHOD',
      # subject
      action_name: nil,
      controller_name: nil,
      email_prefix: nil,
      exception_class_name: nil,
      error_message: nil,
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
      @parse_failure_names = []
      @not_found_names = []
    end

    def subject
      @subject_instance ||= Subject.new(@subject)
    end

    def parse_success?
      @parse_failure_names.empty? && @not_found_names.empty?
    end

    def test(name)
      label = NAME_TABLE[name] || name
      if exists?(label)
        return(
          find_label(label, throw_exception: false) || \
            (@parse_failure_names << name) unless @parse_failure_names.include?(name)
        )
      else
        (@not_found_names << name) unless @not_found_names.include?(name)
      end
      return false
    end

    def has_subject?
      !!@subject
    end

    def get(label)
      return raise('not found name') unless NAME_TABLE.key?(label)
      case label
      when :request_timestamp
        Time.parse(find_label('Timestamp')) if find_label('Timestamp')
      when :action_name, \
        :controller_name, \
        :email_prefix, \
        :exception_class_name, \
        :error_message
        subject.public_send(label)
      else
        find_label(NAME_TABLE[label])
      end
    end

    def get!(label)
      get(label)
    end

    private

    def exists?(name)
      name = name.to_s unless name.is_a?(String)
      @body.include?(name)
    end

    def find(regexp, throw_exception: )
      @body =~ regexp
      $1 || (throw_exception ? raise(ExceptionNotification::Parser::Error, 'parse failed') : nil)
    end

    def find_label(name, throw_exception: true)
      name_to_s = name.to_s
      if @body.include?(name_to_s)
        find(/#{name_to_s} *: "?(.+?)"?$/, throw_exception: throw_exception)
      end
    end
  end
end
