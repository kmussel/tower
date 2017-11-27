defmodule Tower.Config do
  @moduledoc """
  Tower Configuration
  """

  def repo,
    do: Application.get_env(:tower, :repo)

  def generator,
    do: Application.get_env(:tower, :generator)

  def resource_owner,
    do: Application.get_env(:tower, :resource_owner)  
  
  def access_token_methods,
    do: Application.get_env(:tower, :access_token_methods, [:from_bearer_authorization])
end
