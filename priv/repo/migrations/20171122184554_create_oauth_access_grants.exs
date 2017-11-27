defmodule Tower.Repo.Migrations.CreateOauthAccessGrants do
  use Ecto.Migration

  def change do
    create table(:oauth_access_grants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :resource_owner_id, :uuid
      add :application_id, :uuid
      add :token, :string
      add :redirect_uri, :string
      add :expires_in, :integer
      add :details, :jsonb
      add :revoked_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end  
    create index(:oauth_access_grants, [:resource_owner_id])
    create unique_index(:oauth_access_grants, [:token])
  end
end
