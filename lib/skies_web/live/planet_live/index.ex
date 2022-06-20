defmodule SkiesWeb.PlanetLive.Index do
  use SkiesWeb, :live_view

  alias Skies.Planets
  alias SkiesWeb.Live.Components.Body
  alias __MODULE__.Address

  @address "Berkeley CA"
  @elevation 0
  # todo - need to do an elevation lookup on address change
  @today Date.utc_today()
  @tomorrow @today |> Date.add(1)
  @time Time.utc_now() |> Time.truncate(:second)

  @impl true
  def mount(_params, _session, socket) do
    # peer_data = get_connect_info(socket, :peer_data)
    address = @address
    %{latitude: latitude, longitude: longitude} = get_lat_long_from_address(address)

    # get_lat_long(peer_data.address)
    default_params = %{
      latitude: latitude,
      longitude: longitude,
      elevation: @elevation,
      from_date: @today,
      to_date: @tomorrow,
      time: @time
    }

    {:ok,
     %{
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       headers: headers,
       rows: rows
     }} = list_planets(default_params)

    {:ok,
     assign(socket,
       address: address,
       address_changeset: Address.changeset(),
       elevation: elevation,
       from_date: @today,
       to_date: @tomorrow,
       time: @time,
       latitude: latitude,
       longitude: longitude,
       headers: headers,
       rows: rows
     )}
  end

  def handle_event(
        "update_address",
        %{"address" => %{"address" => address}},
        %{assigns: %{elevation: elevation, time: time, from_date: from_date, to_date: to_date}} =
          socket
      ) do
    %{latitude: latitude, longitude: longitude} = get_lat_long_from_address(address)

    {:ok,
     %{
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       headers: headers,
       rows: rows
     }} =
      list_planets(%{
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        from_date: from_date,
        to_date: to_date,
        time: time
      })

    socket =
      assign(socket,
        address: address,
        latitude: latitude,
        longitude: longitude,
        headers: headers,
        rows: rows
      )

    {:noreply, socket}
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

  defp list_planets(params) do
    Planets.list_planets(params)
  end

  defp get_lat_long(ip) do
    #
  end

  defmodule Address do
    defstruct [:address]
    import Ecto.Changeset

    def changeset(address \\ %{address: ""}) do
      types = %{address: :string}

      {%Address{}, types}
      |> cast(address, Map.keys(types))
      |> validate_required([:address])
    end
  end
end
