require 'bunny'
require 'json'
class HomeController < ApplicationController

  def index

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      @@name = @user.name
      redirect_to home_index_path(:name => params[:user][:name])
    else
      render :new
    end

  end

  def self.amqp_url
    services = JSON.parse(ENV['VCAP_SERVICES'], :symbolize_names => true)
    url = services.values.map do |srvs|
      srvs.map do |srv|
        if srv[:label] =~ /^rabbitmq-/
          srv[:credentials][:url]
        else
          []
        end
      end
    end.flatten!.first
  end


#   def self.client
#     unless @client
#       c = Bunny.new
#       c.start
#       @client = c

#     end
#     @client
#   end



#   def self.channel
#     @channel = client.create_channel
#   end

#   def self.nameless_exchange
#     @nameless_exchange ||= channel.fanout("test")
#   end


#   def self.messages_queue  
#     # @messages_queue ||= channel.queue("#{@@name}")
# channel.queue(@@name,   :auto_delete => true).bind(channel).subscribe do |delivery_info, metadata, payload|
#  @messages_queue = "#{payload} => joe"
# end
#   end


  def publish
    
    c = Bunny.new(HomeController.amqp_url)
    c.start
    @client = c   

    @channel = @client.create_channel
    @nameless_exchange = @channel.fanout("test")   

    @queue =   @channel.queue(params[:name]).bind(@nameless_exchange)
      
    if params[:message] != "" 
      message = "#{params[:name]}"+"::"+"#{params[:message]}"
      @nameless_exchange.publish(message)
    end
    
    @msg = @queue.pop.last   
    respond_to do |format|
      format.js
    end

  end

  def get_message  
    @msg = HomeController.messages_queue.pop
    logger.info("##############{@msg.inspect}")
    @msg = @msg.last
    respond_to do |format|
      format.js
      format.html
  end

end
end
