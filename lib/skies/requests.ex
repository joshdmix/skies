defmodule Skies.Requests do
  @moduledoc """
  The Planets context.
  """

  defp request(url, options \\ []) do
    auth_hash = "Basic #{Application.get_env(:skies, :hash)}"
    headers = [Authorization: auth_hash]

    HTTPoison.get(url, headers, options)
  end

  defp post_request(url, body) do
    auth_hash = "Basic #{Application.get_env(:skies, :hash)}"
    headers = [Authorization: auth_hash]

    HTTPoison.post(url, body, headers)
  end

  @type bodies_request :: %{
          latitude: integer(),
          longitude: integer(),
          elevation: integer(),
          from_date: Date.t(),
          to_date: Date.t(),
          time: Time.t()
        }

  @type bodies_response ::
          {:ok,
           %{
             elevation: String.t(),
             latitude: String.t(),
             longitude: String.t(),
             headers: [map()],
             rows: [map()]
           }}

  @spec bodies_request(bodies_request()) :: bodies_response()
  def bodies_request(params) do
    params |> Enum.map(fn {k, v} -> {k, to_string(v)} end)

    options = [params: params]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           request("https://api.astronomyapi.com/api/v2/bodies/positions", options) do
      body |> Jason.decode!() |> format_bodies_response()
    end
  end

  defp format_bodies_response(resp_body) do
    observer = resp_body["data"]["observer"]["location"]

    headers =
      resp_body["data"]["table"]["header"]
      |> Enum.map(fn dt ->
        {:ok, dt, _} = DateTime.from_iso8601(dt)
        DateTime.truncate(dt, :second)
      end)

    rows =
      resp_body["data"]["table"]["rows"]
      |> Enum.map(&handle_response_row/1)
      |> List.flatten()

    {:ok,
     %{
       elevation: observer["elevation"],
       latitude: observer["latitude"],
       longitude: observer["longitude"],
       headers: headers,
       rows: rows
     }}
  end

  # observer \\ %{date: @today, latitude: @lat, longitude: @long},
  # view \\ %{type: "portrait-simple"},
  # style \\ %{"moonStyle" => "sketch", "backgroundStyle" => "stars"}
  def moon_phase_request(
        observer,
        view,
        style
      ) do
    body = %{observer: observer, style: style, view: view} |> Jason.encode!()

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           post_request(
             "https://api.astronomyapi.com/api/v2/studio/moon-phase",
             body
           ) do
      %{"data" => %{"imageUrl" => image_url}} = Jason.decode!(body)

      {:ok, image_url}
    end
  end

  # observer \\ %{date: @today, latitude: @lat, longitude: @long},
  # view \\ %{type: "constellation", parameters: %{constellation: "ori"}}
  def star_chart_request(
        # todo - why does this timeout?
        observer,
        view
      ) do
    body = %{observer: observer, view: view} |> Jason.encode!()

    post_request(
      "https://api.astronomyapi.com/api/v2/studio/star-chart",
      body
    )
  end

  def position_request(address) do
    position_stack_key = Application.get_env(:skies, :position)

    url =
      "http://api.positionstack.com/v1/forward?access_key=#{position_stack_key}&query=#{address}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- request(url) do
      %{
        # "administrative_area" => nil,
        # "confidence" => 0.6,
        # "continent" => "North America",
        # "country" => "United States",
        # "country_code" => "USA",
        "county" => county,
        # "label" => "Boulder, CO, USA",
        "latitude" => latitude,
        "locality" => locality,
        "longitude" => longitude,
        # "name" => name,
        # "neighbourhood" => nil,
        # "number" => nil,
        # "postal_code" => nil,
        # "region" => "Colorado",
        "region_code" => region_code
        # "street" => nil,
        # "type" => "locality"
      } = body |> Jason.decode!() |> Map.get("data") |> List.first()

      # todo - currently this assumes first position result is correct

      {:ok,
       %{
         latitude: latitude,
         longitude: longitude,
         city: locality,
         state: region_code,
         county: county
       }}
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
    allowed = ~w(date distance extra_info id name position horizontal)

    cell |> keys_to_snakecase |> Map.take(allowed) |> keys_to_atoms
  end

  def keys_to_snakecase(json) when is_map(json) do
    Map.new(json, &reduce_keys_to_snakecase/1)
  end

  defp reduce_keys_to_snakecase({key, val}) when is_map(val),
    do: {Macro.underscore(key), keys_to_snakecase(val)}

  defp reduce_keys_to_snakecase({key, val}) when is_list(val),
    do: {Macro.underscore(key), Enum.map(val, &keys_to_snakecase(&1))}

  defp reduce_keys_to_snakecase({key, val}), do: {Macro.underscore(key), val}

  def keys_to_atoms(json) when is_map(json) do
    Map.new(json, &reduce_keys_to_atoms/1)
  end

  defp reduce_keys_to_atoms({key, val}) when is_map(val),
    do: {String.to_atom(key), keys_to_atoms(val)}

  defp reduce_keys_to_atoms({key, val}) when is_list(val),
    do: {String.to_atom(key), Enum.map(val, &keys_to_atoms(&1))}

  defp reduce_keys_to_atoms({key, val}), do: {String.to_atom(key), val}
end
