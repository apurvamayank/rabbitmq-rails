module ApplicationHelper

  def msg_helper(msg,name,exchange)
    if msg != ""
      message = "#{name}"+"::"+"#{msg}"
    else
      return nil
    end
  end
end
