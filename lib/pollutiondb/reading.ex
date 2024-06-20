defmodule Pollutiondb.Reading do
  # alias ElixirLS.LanguageServer.Plugins.Ecto
  use Ecto.Schema
  require Ecto.Query

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float
    belongs_to :station, Pollutiondb.Station
  end

  def add_now(station, type, value) do
    changesmap = %{type: type, value: value, station_id: station, date: Date.utc_today(), time: Time.utc_now()}
    %Pollutiondb.Reading{}
    |> changeset(changesmap)
    |> Pollutiondb.Repo.insert
  end

  def add(station, date, time, type, value) do
    changesmap = %{type: type, value: value, station_id: station, date: Date.from_erl!(date), time: Time.from_erl!(time) }

    %Pollutiondb.Reading{}
    |> changeset(changesmap)
    |> Pollutiondb.Repo.insert

  end

  defp changeset(reading, changesmap) do
    reading
    |> Ecto.Changeset.cast(changesmap, [:date, :time, :type, :value, :station_id])
    |> Ecto.Changeset.cast_assoc(:station)
    |> Ecto.Changeset.validate_required([:date, :time, :type, :value])
  end

  def find_by_date(date) do
    Pollutiondb.Repo.all( Ecto.Query.where(Pollutiondb.Station,date: ^date))
  end


end
