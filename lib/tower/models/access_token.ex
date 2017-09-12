defmodule Tower.Models.AccessToken do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :token,
    :resource_owner_id,
    :application_id
  ]

  @resource_owner Application.get_env(:tower, :resource_owner)
  @expires_in Application.get_env(:tower, :expires_in, 7200)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Poison.Encoder, except: [:__meta__]}
  schema "access_tokens" do
    field :token, :string
    field :refresh_token, :string
    field :expires_in, :integer
    field :details, :map
    field :revoked_at, :utc_datetime
    belongs_to :resource_owner, @resource_owner
    belongs_to :application, Tower.Models.OAuthApplication
    timestamps()
  end

  @doc """
  alias Tower.Models.AccessToken  
  changeset = AccessToken.changeset(%AccessToken{}, %{token: "12321321312", resource_owner_id: 1})
  repo.insert(changeset)
  """  
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:resource_owner_id)    
    |> foreign_key_constraint(:application_id)    
    |> unique_constraint(:access_tokens_token_constraint, name: :access_tokens_token_index)
    |> change(params)
  end
end
