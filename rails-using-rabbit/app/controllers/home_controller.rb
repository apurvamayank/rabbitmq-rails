require 'bunny'
require 'json'

class HomeController < ApplicationController

  def index
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


  def self.client
    unless @client
      client = Bunny.new(amqp_url)
      client.start
      @client = client
      @client.qos :prefetch_count => 1
    end
    @client
  end


  def self.nameless_exchange
    @nameless_exchange ||= client.exchange('')
  end

  def self.messages_queue
    @messages_queue ||= client.queue("messages")
  end


  def publish

    HomeController.nameless_exchange.publish params[:message],
                                             :key => "messages"


    respond_to do |format|
      format.js
    end
  end

  def get_message
    @msg = HomeController.messages_queue.pop[:payload]

    respond_to do |format|
      format.js
      format.html
    end
  end
end