require 'rest-client'
require 'faye/websocket'
require 'eventmachine'
require 'lita/adapters/discord/api'
require 'lita/adapters/discord/token_cache'

module Lita
	module Adapters
		class Discord < Adapter
			class Client
				def initialize(email, password)
					@email = email
					@password = password
					@token_cache = TokenCache.new
					@channels = {}
					@users = {}
					@restricted_channels = []
					@event_threads = []
					@current_thread = 0
				end

				def connect
					@token = login
				end

				def disconnect
					API.logout
				end


				private

				def login
					if @email == :token
						Lita.logger.debug('Logging in using static token')
						# The password is the token!
						return @password
					end

					Lita.logger.debug('Logging in')
					login_attempts ||= 0

					# First, attempt to get the token from the cache
					token = @token_cache.token(@email, @password)

					if token
						Lita.logger.debug('Token successfully obtained from cache!')
						return token
					end
					require_relative 'api'
					# Login
					login_response = API.login(@email, @password)
					# raise Discordrb::Errors::HTTPStatusError, login_response.code if login_response.code >= 400

					# Parse response
					login_response_object = JSON.parse(login_response)
					# raise Discordrb::Errors::InvalidAuthenticationError unless login_response_object['token']
					
					Lita.logger.debug('Received token from Discord!')

					# Cache the token
					@token_cache.store_token(@email, @password, login_response_object['token'])

					login_response_object['token']
					# rescue Exception => e
					# response_code = login_response.nil? ? 0 : login_response.code ######## mackmm145
					# if login_attempts < 100 && (e.inspect.include?('No such host is known.') || response_code == 523)
					# 	Lita.logger.debug("Login failed! Reattempting in 5 seconds. #{100 - login_attempts} attempts remaining.")
					# 	Lita.logger.debug("Error was: #{e.inspect}")
					# 	sleep 5
					# 	login_attempts += 1
					# 	retry
					# else
					# 	Lita.logger.debug("Login failed permanently after #{login_attempts + 1} attempts")
					# 	# Apparently we get a 400 if the password or username is incorrect. In that case, tell the user
					# 	Lita.logger.debug("Are you sure you're using the correct username and password?") if e.class == RestClient::BadRequest
					# 	# raise $ERROR_INFO
					# end
				end

				def logout
					
				end
			end
		end
	end
end