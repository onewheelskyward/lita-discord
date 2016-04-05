require 'base64'
require 'json'
require 'openssl'
require_relative 'api'

module Lita
	module Adapters
		class Discord < Adapter
			KEYLEN = 32
			CACHE_PATH = Dir.pwd + '/.discord_token_cache.json'
			class CachedToken
				def initialize(data = nil)
					if data
						@verify_salt = Base64.decode64(data['verify_salt'])
						@password_hash = Base64.decode64(data['password_hash'])
						@encrypt_salt = Base64.decode64(data['encrypt_salt'])
						@iv = Base64.decode64(data['iv'])
						@encrypted_token = Base64.decode64(data['encrypted_token'])
					else
						generate_salts
					end
				end

				# @return [Hash<Symbol => String>] the data representing the token and encryption data, all encrypted and base64-encoded
			    def data
					{
						verify_salt: Base64.encode64(@verify_salt),
						password_hash: Base64.encode64(@password_hash),
						encrypt_salt: Base64.encode64(@encrypt_salt),
						iv: Base64.encode64(@iv),
						encrypted_token: Base64.encode64(@encrypted_token)
					}
				end

				def verify_password(password)
					hash_password(password) == @password_hash
				end

				def generate_verify_hash(password)
					@password_hash = hash_password(password)
				end

				def obtain_key(password)
					@key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, @encrypt_salt, 300_000, KEYLEN)
				end

				def generate_salts
					@verify_salt = OpenSSL::Random.random_bytes(KEYLEN)
					@encrypt_salt = OpenSSL::Random.random_bytes(KEYLEN)
				end

				def decrypt_token(password)
					key = obtain_key(password)
					decipher = OpenSSL::Cipher::AES256.new(:CBC)
					decipher.decrypt
					decipher.key = key
					decipher.iv = @iv
					decipher.update(@encrypted_token) + decipher.final
				end

				def encrypt_token(password, token)
					key = obtain_key(password)
					cipher = OpenSSL::Cipher::AES256.new(:CBC)
					cipher.encrypt
					cipher.key = key
					@iv = cipher.random_iv
					@encrypted_token = cipher.update(token) + cipher.final
				end

				def test_token(token)
					API.validate_token(token)
				end

				def hash_password(password)
					digest = OpenSSL::Digest::SHA256.new
					OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, @verify_salt, 300_000, digest.digest_length, digest)
				end
			end

			class TokenCache

				def initialize
					if File.file? CACHE_PATH
						@data = JSON.parse(File.read(CACHE_PATH))
					else
						Lita.logger.debug("Cache file #{CACHE_PATH} not found. Using empty cache")
						@data = {}
					end
				rescue => e
					Lita.logger.debug('Exception occurred while parsing token cache file:')
					# I guess start here if stuff is super broken
					Lita.logger.debug('Continuing with empty cache')
					@data = {}
				end

				def token(email, password)
					if @data[email]
						begin
							cached = CachedToken.new(@data[email])
							if cached.verify_password(password)
								token = cached.decrypt_token(password)
								if token
									begin
										cached.test_token
										token
									rescue => e
										fail_token('Token cached, verified and decrypted, but rejected by Discord', email)
										sleep 1
										nil
									end
								else
									fail_token('Token cached and verified, but decryption failed', email)
								end
							else
								fail_token('Token verification failed', email)
							end
						rescue => e
							fail_token('Token cached but invalid', email)
						end
					else
						fail_token('Token not cached at all')
					end
				end

				def store_token(email, password, token)
					cached = CachedToken.new
					cached.generate_verify_hash(password)
					cached.encrypt_token(password, token)
					@data[email] = cached.data
					write_cache
				end

				def write_cache
					File.write(CACHE_PATH, @data.to_json)
				end

				private

				def fail_token(msg, email = nil)
					Lita.logger.warn("Token not retrieved from cache - #{msg}")
					@data.delete(email) if email
					nil
				end
				
			end
		end
	end
end