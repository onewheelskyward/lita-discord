require_relative "discord/client"

module Lita
  module Adapters
    class Discord < Adapter
      config :email, type: String, required: true
      config :password, type: String, required: true

      def initialize(robot)
      	super

      	## TIME TO REBUILD THIS SHIZZZZZZ
      	@client = Client.new(config.email, config.password)
      end

     #  def run
     #  	@client.on_connect do
					# robot.trigger(:connected)      		
     #  	end

     #  	@client.on_message do |message, user, channel|
     #  		user = Lita::User.find_by_name(user)
     #  		user = Lita::User.create(user) unless user
     #  		source = Lita::Source.new(user: user, room: channel)
     #  		message = Lita::Message.new(robot, message, source)
     #  		robot.receive(message)
     #  	end

     #  	@client.connect
     #  end

      # def shut_down
      # 	@client.disconnect
      # end

      # def mention_format(user_id)
      # 	"@<#{user_id}>"
      # end

      # Referenced https://github.com/litaio/lita-slack/blob/master/lib/lita/adapters/slack.rb#L46
      # Trying to build out basic commands for max plugin compatibility 
      # Update when api is built out
      # def set_topic(target, topic)

      	
      # end

      Lita.register_adapter(:discord, self)
    end
  end
end
