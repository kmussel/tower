defmodule Tower.Repo.Migrations.CreateOauthApplication do
  use Ecto.Migration

  def change do
    create table(:oauth_applications, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :uid, :string
      add :secret, :string
      add :redirect_uri, :string
      add :settings, :jsonb
      add :scopes, :string

      timestamps(type: :utc_datetime)
    end  
    create unique_index(:oauth_applications, [:uid])
  end
end
