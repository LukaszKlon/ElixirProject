defmodule DataLoader do

  def load_station(path) do
    file = File.read!(path)
    add_stations(file)
  end

  def load_readings(path) do
    file = File.read!(path)
    add_readings(file)
  end

  defp add_stations(file) do
    file
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&Parser.single_line_split(&1))
    |> Enum.uniq_by(& &1.location)
    |> Enum.each(&  add_station(&1))
  end

  defp add_station(station) do
    # IO.puts(station)
    {x,y} = station.location
    Pollutiondb.Station.add(station.stationName,x,y)
  end

  defp add_readings(file) do
    file
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&Parser.single_line_split(&1))
    |> Enum.each(& add_reading(&1))
  end

  defp add_reading(station) do
    # IO.puts(station.stationName)
    id = Pollutiondb.Station.find_by_name_id(station.stationName)
    # IO.puts(station.dateTime)
    {date,time} = station.dateTime
    Pollutiondb.Reading.add(id,date,time,station.pollutionType,station.pollutionLevel)
  end

end

# " DataLoader.load("C:/Users/klonl/OneDrive/Pulpit/STUDIA/semestr4/ErlangIElixir/Lab6/AirlyData-ALL-50k.csv") "

defmodule Parser do
  def single_line_split(line) do
    [datetime, pollutionType, pollutionLevel, stationID, stationName, cords] =
      line |> String.split(";")

    %{
      # :stationName => prepare_station(stationName),
      :stationName => stationID <> " " <> stationName,
      :location => prepare_cords(cords),
      :pollutionType => pollutionType,
      :pollutionLevel => String.to_float(pollutionLevel),
      :StationID => String.to_integer(stationID),
      :dateTime => prepare_time(datetime)
    }
  end

  # defp prepare_station(station) do
  #   station
  #   |> String.split(",")
  # end


  defp prepare_cords(cords) do
    cords
    |> String.split(",")
    |> Enum.map(&String.to_float(&1))
    |> List.to_tuple()
  end

  defp prepare_time(dateTime) do
    [date, time] = dateTime |> String.split("T")
    {convert_date(date), convert_time(time)}
  end

  defp convert_date(date) do
    date
    |> String.split("-")
    |> Enum.map(&String.to_integer(&1))
    |> List.to_tuple()
  end

  defp convert_time(time) do
    length = String.length(time)
    slice = String.slice(time, 0, length - 5)

    slice
    |> String.split(":")
    |> Enum.map(&String.to_integer(&1))
    |> List.to_tuple()
  end
end
