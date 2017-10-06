defmodule Tower.Repo.Migrations.CreateAccessToken do
  use Ecto.Migration

  def change do
    create table(:access_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :resource_owner_id, :uuid
      add :application_id, :uuid
      add :token, :string
      add :refresh_token, :string
      add :expires_in, :integer
      add :details, :jsonb
      add :revoked_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
    create index(:access_tokens, [:resource_owner_id])
    create unique_index(:access_tokens, [:token])
  end
end
