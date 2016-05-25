class ExceptionNotification::Parser::Subject
  NAMES = [
    :action_name,
    :controller_name,
    :email_prefix,
    :exception_class_name,
    :error_message
  ]

  def initialize(subject)
    @subject = subject
  end

  def get(name)
    find_value(name)
  end

  def get!(name)
    value = find_value(name)
    return value if value
    raise(
      ExceptionNotification::Parser::Error,
      "#{@subject}:no match pattaern subject!"
    ) if (@parse_failure || return)
  end

  def to_s
    @subject
  end

  private

  def find_value(name)
    return unless NAMES.include?(name)
    set_values! unless defined?(@parse_failure)
    instance_variable_get("@#{name}")
  end

  def set_values!
    if %r!^([^ ]+) \(([^)]+)\) ?(".*")?!m =~ @subject
      @email_predix = $1
      @controller_name = nil
      @action_name = nil
      @exception_class_name = $2
      @error_message = $3
      @parse_failure = false
      return
    end

    if %r!([^ ]+) ([^#]*?)#(\w*?) \(([^\)]+?)\) ?(".*")?!m =~ @subject
      @email_prefix = $1
      @controller_name = $2
      @action_name = $3
      @exception_class_name = $4
      @error_message = $5
      @parse_failure = false
      return
    end
    @parse_failure = true
  end
end
