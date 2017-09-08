defmodule Tower do
  @moduledoc """
  Documentation for Tower.
  """
  use Application


  @repo Application.get_env(:tower, :repo)

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
    ]

    opts = [strategy: :one_for_one, name: Tower.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
