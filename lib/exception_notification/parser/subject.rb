class ExceptionNotification::Parser::Subject
  attr_reader \
    :action_name,
    :controller_name,
    :email_prefix,
    :exception_class_name

  def initialize(subject)
    @subject = subject
    if %r!^([^ ]+) \(([^)]+)\)!m =~ subject
      @email_predix = $1
      @controller_name = nil
      @action_name = nil
      @exception_class_name = $2
      return
    end

    if %r!([^ ]+) ([^#]+?)#(\w+) \(([^\)]+?)\)!m =~ subject
      @email_prefix = $1
      @controller_name = $2
      @action_name = $3
      @exception_class_name = $4
      return
    end

    raise("#{subject}:no match pattaern subject!")
  end

  def to_s
    @subject
  end
end
