defmodule SkiesWeb.PlanetLive.Index do
  use SkiesWeb, :live_view

  alias Skies.Planets
  alias SkiesWeb.Live.Components.Body

  @impl true
  def mount(_params, _session, socket) do
    peer_data = get_connect_info(socket, :peer_data)

    get_lat_long(peer_data.address)

    {:ok,
     %{
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       data: data
     }} = list_planets()

    headers =
      data.header
      |> Enum.map(fn dt ->
        {:ok, dt, _} = DateTime.from_iso8601(dt)
        DateTime.truncate(dt, :second)
      end)

    rows = data.rows

    {:ok,
     assign(socket,
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       data: data,
       headers: headers,
       rows: rows
     )}
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  defp list_planets do
    Planets.list_planets()
  end

  defp get_lat_long(ip) do
    IO.inspect(ip)
  end
end
