module HomeHelper

  def msg_helper(msg,name,exchange)
    if msg != ""
      message = "#{name}"+"::"+"#{msg}"
      exchange.publish(message)
    else
      return nil
    end
  end
end
