defmodule Tower.Models.OAuthApplication do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :name,
    :uid,
    :secret
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Poison.Encoder, except: [:__meta__]}
  schema "oauth_applications" do
    field :name, :string
    field :uid, :string
    field :secret, :string
    field :redirect_uri, :string
    field :settings, :map
    field :scopes, :string
    timestamps()
  end

  @doc """
  alias Tower.Models.OAuthApplication  
  changeset = Tower.Models.OAuthApplication.changeset(%Tower.Models.OAuthApplication{}, %{name: "app_name", uid: "12321321312", secret: "3213123"})
  repo.insert(changeset)
  """  
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:oauth_applications_uid_constraint, name: :oauth_applications_uid_index)
    |> change(params)
  end
end
