require 'rest-client'
require 'json'

module Lita
	module Adapters
		class Discord < Adapter
			class API
				APIBASE = 'https://discordapp.com/api'.freeze

				def user_agent
				    # This particular string is required by the Discord devs.
				    required = "lita-discord (https://github.com/kyleboe/lita-discord, v0.1.0)"
					@bot_name ||= ''

					"rest-client/#{RestClient::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} lita-discord/0.1.0 #{required} #{@bot_name}"
				end

				# Referenced https://github.com/meew0/discordrb/blob/9897dad08370d4de5de738c8f6c27b8c7764c429/lib/discordrb/api.rb#L35
				def raw_request(type, attributes)
				    RestClient.send(type, *attributes)
					rescue RestClient::Forbidden
					raise Lita.logger.debug("The bot doesn't have the required permission to do this!")
				end

				def request(type, *attributes)
					# Add a custom user agent
				    attributes.last[:user_agent] = user_agent if attributes.last.is_a? Hash
				    response = raw_request(type, attributes)

				    while response.code == 429
				    	wait_seconds = response[:retry_after].to_i / 1000.0
				    	Lita.logger.debug("WARNING: Discord rate limiting will cause a delay of #{wait_seconds} seconds for the request: #{type} #{attributes}")
				    	sleep wait_seconds / 1000.0
				    	response = raw_request(type, attributes)
					end
					response				
				end

				# Make an avatar URL from the user and avatar IDs
				def avatar_url(user_id, avatar_id)
					"#{APIBASE}/users/#{user_id}/avatars/#{avatar_id}.jpg"
				end

				# Login to the server
				def login(email, password)
					request( :post, "#{APIBASE}/auth/login", email: email, password: password )
				end

				# Logout from the server
				def logout(token)
					request( :post, "#{APIBASE}/auth/logout", nil, Authorization: token )
				end

				def validate_token(token)
					request( :post, "#{APIBASE}/auth/login",{}.to_json, Authorization: token, content_type: :json )
				end

				def user(token, user_id)
					request( :get, "#{APIBASE}/users/#{user_id}", Authorization: token )
				end
			end
		end
	end
end