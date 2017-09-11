defmodule Tower.Utils.Router do
  @doc """
  Forwards requests to another Plug. This is defined in Plug.Router but the 
  guard clause keeps us from being able to pass a variable as the path.  
  The variable is needed in order for an application to override the route path.
  The rest of the method is the exact same. 
  """  

  defmacro forward(path, options) do
    quote bind_quoted: [path: path, options: options] do
      {target, options}       = Keyword.pop(options, :to)
      {options, plug_options} = Keyword.split(options, [:host, :private, :assigns])
      plug_options = Keyword.get(plug_options, :init_opts, plug_options)

      if is_nil(target) or !is_atom(target) do
        raise ArgumentError, message: "expected :to to be an alias or an atom"
      end

      @plug_forward_target target
      @plug_forward_opts   target.init(plug_options)

      # Delegate the matching to the match/3 macro along with the options
      # specified by Keyword.split/2.
      match path <> "/*glob", options do
        Plug.Router.Utils.forward(
          var!(conn),
          var!(glob),
          @plug_forward_target,
          @plug_forward_opts
        )
      end
    end
  end
end
