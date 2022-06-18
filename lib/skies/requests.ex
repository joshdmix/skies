defmodule Skies.Requests do
  @moduledoc """
  The Planets context.
  """
  @lat 38.253
  @long -85.758
  @elevation 500
  @today Date.utc_today()
  @tomorrow @today |> Date.add(1)
  @time Time.utc_now() |> Time.truncate(:second)

  defp request(url, options \\ []) do
    auth_hash = "Basic #{Application.get_env(:skies, :hash)}" |> IO.inspect(label: "hash")
    headers = [Authorization: auth_hash]

    {:ok, response} = HTTPoison.get(url, headers, options)
  end

  def bodies_request do
    params =
      [
        latitude: @lat,
        longitude: @long,
        elevation: @elevation,
        from_date: @today,
        to_date: @tomorrow,
        time: @time
      ]
      |> Enum.map(fn {k, v} -> {k, to_string(v)} end)

    options = [params: params]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           request("https://api.astronomyapi.com/api/v2/bodies/positions", options) do
      body = body |> Jason.decode!()

      observer = body["data"]["observer"]
      latitude = observer["location"]["latitude"]
      longitude = observer["location"]["longitude"]

      header = body["data"]["table"]["header"]

      rows =
        body["data"]["table"]["rows"]
        |> Enum.map(&handle_response_row/1)
        |> List.flatten()

      {:ok, %{latitude: latitude, longitude: longitude, data: %{header: header, rows: rows}}}
    end
  end

  # defp body_changeset(params) do
  #   types = %{
  #     date: :string,
  #     distance: :map,
  #     id: :string,
  #     name: :string,
  #     position: :map,
  #     extra_info: :map
  #   }

  #   changeset =
  #     {params, types}
  #     |> Ecto.Changeset.cast(%{}, Map.keys(types))
  #     |> Ecto.Changeset.validate_required([:id, :name, :position])
  # end

  defp handle_response_row(%{"cells" => cells}) do
    %{cells: cells |> Enum.map(&handle_response_cell/1)}
  end

  defp handle_response_cell(cell) do
    allowed = ~w(date distance extraInfo id name position horizontal)

    cell |> Map.take(allowed) |> keys_to_atoms
  end

  def keys_to_atoms(json) when is_map(json) do
    Map.new(json, &reduce_keys_to_atoms/1)
  end

  defp reduce_keys_to_atoms({key, val}) when is_map(val),
    do: {String.to_atom(key), keys_to_atoms(val)}

  defp reduce_keys_to_atoms({key, val}) when is_list(val),
    do: {String.to_atom(key), Enum.map(val, &keys_to_atoms(&1))}

  defp reduce_keys_to_atoms({key, val}), do: {String.to_atom(key), val}
end