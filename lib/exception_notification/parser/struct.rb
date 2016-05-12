module ExceptionNotification::Parser
  class Struct
    attr_reader :body, :subject

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
    end

    def subject
      Subject.new(@subject)
    end

    def has_subject?
      !!@subject
    end

    def request_url
      find(/URL[ ]*: (.*)$/)
    end

    def request_http_method
      find_label('HTTP Method')
    end

    def request_ip_address
      find_label('IP address')
    end

    def request_timestamp
      Time.parse(find_label('Timestamp')) if find_label('Timestamp')
    end

    def requist_rails_root
      find_label('Rails root')
    end

    def requist_parameters
      find_label_for_hash(:Parameters)
    end

    def session_id
      find_label('session id').gsub('"', '')
    end

    def session_data
      find_label_for_hash(:data)
    end

    def environment_content_length
      find_label(:CONTENT_LENGTH).to_i
    end

    def environment_content_type
      find_label(:CONTENT_TYPE)
    end

    def environment_http_host
      find_label(:HTTP_HOST)
    end

    def environment_http_user_agent
      find_label(:HTTP_USER_AGENT)
    end

    def environment_remote_addr
      find_label(:REMOTE_ADDR)
    end

    def environment_request_path
      find_label(:REQUEST_PATH)
    end

    def environment_request_uri
      find_label(:REQUEST_URI)
    end

    def environment_request_method
      find_label(:REQUEST_METHOD)
    end

    private

    def find(regexp)
      @body =~ regexp
      $1 || raise(ExceptionNotification::Parser::Error, 'parse failed')
    end

    def find_label(name)
      name_to_s = name.to_s
      if has_key?(name_to_s)
        find(/#{name_to_s} *: (.+?)$/)
      end
    end

    def find_label_for_hash(name)
      data = {}
      lines = find(/ *\* #{name} *: {(.*?)}$/m)
      lines.split(',').each do |line|
        splited = line.gsub('"', '').strip.split('=>')
        data[splited[0]] = splited[1]
      end
      data
    end

    def has_key?(name)
      @body.include?(name)
    end
  end
end
