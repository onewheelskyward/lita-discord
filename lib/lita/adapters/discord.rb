module Lita
  module Adapters
    class Discord < Adapter
      # insert adapter code here

      Lita.register_adapter(:discord, self)
    end
  end
end
