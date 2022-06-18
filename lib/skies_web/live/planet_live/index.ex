defmodule SkiesWeb.PlanetLive.Index do
  use SkiesWeb, :live_view

  alias Skies.Planets
  alias Skies.Planets.Planet

  @impl true
  def mount(_params, _session, socket) do
    {:ok, %{latitude: latitude, longitude: longitude, data: data}} = list_planets()

    headers =
      data.header
      |> Enum.map(fn dt ->
        {:ok, dt, _} = DateTime.from_iso8601(dt)
        DateTime.truncate(dt, :second)
      end)

    rows = data.rows

    {:ok,
     assign(socket,
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
end
