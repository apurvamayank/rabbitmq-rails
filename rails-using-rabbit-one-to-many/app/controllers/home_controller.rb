require 'bunny'
require 'json'
class HomeController < ApplicationController

  def index

  end

  def new
    @user = User.new
  end

  def create
    redirect_to home_index_path(:name => params[:user][:name])
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



  def publish
    client = client_initialization
    channel = client.create_channel
    nameless_exchange = channel.fanout("test")
    queue =   channel.queue(params[:name]).bind(nameless_exchange)
      nameless_exchange.publish("#{params[:name]}"+"::"+"#{params[:message].to_s}")   if params[:message].present?
    @msg = @queue.pop.last
    respond_to do |format|
      format.js
    end

  end



  private

  def client_initialization
    client = Bunny.new
    client.start
    client
  end

end
