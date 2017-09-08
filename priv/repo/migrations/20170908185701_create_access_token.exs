defmodule Tower.Repo.Migrations.CreateAccessToken do
  use Ecto.Migration

  def change do
    create table(:access_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :resource_owner_id, :uuid
      add :application_id, :uuid
      add :token, :binary
      add :refresh_token, :binary
      add :expires_in, :integer
      add :details, :jsonb
      add :revoked_at, :datetime

      timestamps()
    end
    create index(:access_tokens, [:resource_owner_id])
    create unique_index(:access_tokens, [:token])
  end
end
