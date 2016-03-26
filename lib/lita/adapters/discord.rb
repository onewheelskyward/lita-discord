module Lita
  module Adapters
    class Discord < Adapter
      config :email, type: String, required: true
      config :password, type: String, required: true
      

      Lita.register_adapter(:discord, self)
    end
  end
end
