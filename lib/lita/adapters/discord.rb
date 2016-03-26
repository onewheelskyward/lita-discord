module Lita
  module Adapters
    class Discord < Adapter
      config :email, type: String, required: true
      config :password, type: String, required: true


      def mention_format(user_id)
      	"@<#{user_id}>"
      end

      # Referenced https://github.com/litaio/lita-slack/blob/master/lib/lita/adapters/slack.rb#L46
      # Trying to build out basic commands for max plugin compatibility 
      # Update when api is built out
      def set_topic(target, topic)

      	
      end

      Lita.register_adapter(:discord, self)
    end
  end
end
