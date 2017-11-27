defmodule Tower.Models.AccessGrant do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :token,
    :resource_owner_id,
    :application_id
  ]

  import Tower.Config, only: [resource_owner: 0]


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Poison.Encoder, except: [:__meta__]}
  schema "oauth_access_grants" do
    field :token, :string
    field :redirect_uri, :string
    field :expires_in, :integer
    field :details, :map
    field :revoked_at, :utc_datetime
    belongs_to :resource_owner, resource_owner()
    belongs_to :application, Tower.Models.OAuthApplication
    timestamps(type: :utc_datetime)
  end

  @doc """
  alias Tower.Models.AccessGrant  
  changeset = AccessGrant.changeset(%AccessGrant{}, %{token: "12321321312", resource_owner_id: 1})
  repo.insert(changeset)
  """  
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:resource_owner_id)    
    |> foreign_key_constraint(:application_id)
    |> unique_constraint(:oauth_access_grants_token_constraint, name: :oauth_access_grants_token_index)
    |> change(params)
  end

  def revoke(token) do 
    token
    |> Tower.Models.AccessGrant.changeset(%{revoked_at: DateTime.utc_now})
    |> Tower.Repo.update()
  end

  def is_expired?(token) do
    (DateTime.to_unix(token.inserted_at) + token.expires_in) < :os.system_time(:seconds)
  end

  def has_scopes(_, []), do: true
  def has_scopes(token, required_scopes) when is_list(required_scopes) do
    details = token.details || %{}
    scopes = String.split(Map.get(details, "scopes", ""), ~r{,\s*})
    required_scopes
    |> Enum.find(fn(item) -> !Enum.member?(scopes, item); end)
    |> is_nil
  end
  def has_scopes(_, _), do: false
end
