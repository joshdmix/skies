defmodule SkiesWeb.PlanetLive.Index do
  use SkiesWeb, :live_view

  alias Skies.Planets
  alias SkiesWeb.Live.Components.Body
  alias __MODULE__.Address

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

    address_changeset = Address.changeset() |> IO.inspect()

    {:ok,
     assign(socket,
       address: "",
       address_changeset: address_changeset,
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       data: data,
       headers: headers,
       rows: rows
     )}
  end

  def handle_event("update_address", %{"address" => %{"address" => address}}, socket) do
    %{latitude: latitude, longitude: longitude} = get_lat_long_from_address(address)

    {:noreply,
     assign(socket,
       address: address,
       latitude: latitude,
       longitude: longitude
       #  elevation: elevation
     )}

    # get_lat_long_from_address(address)
  end

  defp get_lat_long_from_address(address) do
    with {:ok, position} <- Skies.Requests.position_request(address) do
      position
    end
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  defp list_planets do
    Planets.list_planets()
  end

  defp get_lat_long(ip) do
    #
  end

  defmodule Address do
    defstruct [:address]
    import Ecto.Changeset

    def changeset(address \\ %{address: "500 Main St Boulder CO"}) do
      types = %{address: :string}

      {%Address{}, types}
      |> cast(address, Map.keys(types))
      |> validate_required([:address])
    end
  end
end
