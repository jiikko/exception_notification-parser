class ExceptionNotification::Parser::Subject
  attr_reader :controller_name, :action_name, :exception_class_name

  def initialize(subject)
    @subject = subject
    if %r!^\[.+?\] \(([^)]+)\)!m =~ subject
      @controller_name = nil
      @action_name = nil
      @exception_class_name = $1
      return
    end

    if %r!\[\w+\] ([^ ]+)+#(\w+) \(([^\)]+?)\)!m =~ subject
      @controller_name = $1
      @action_name = $2
      @exception_class_name = $3
      return
    end

    raise('no match pattaern subject!')
  end

  def to_s
    @subject
  end
end
