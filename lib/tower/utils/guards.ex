defmodule Tower.Utils.Guards do
  @doc """
  Guard Macros
  """  
    
  @moduledoc """
  Getting the access token metnods from the config env variable.
  """
  defmacro access_token_methods() do      
    quote do        
      unquote(Tower.Config.access_token_methods())
    end
  end
end
