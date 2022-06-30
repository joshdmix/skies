defmodule SkiesWeb.PlanetLive.Index do
  use SkiesWeb, :live_view

  alias Skies.Planets
  alias SkiesWeb.Live.Components.Body
  alias __MODULE__.Address

  @address "Portsmouth NH"
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
      to_date: @today,
      time: @time
    }

    {:ok,
     %{
       earth: earth,
       elevation: elevation,
       latitude: latitude,
       longitude: longitude,
       headers: headers,
       rows: rows
     }} = list_planets(default_params)

    rows = Enum.map(rows, &add_class_to_cells/1)

    {:ok, moon_phase_url} =
      Skies.Requests.moon_phase_request(
        %{date: @today, latitude: latitude, longitude: longitude},
        %{type: "portrait-simple"},
        %{"moonStyle" => "sketch", "backgroundStyle" => "stars"}
      )

    {:ok,
     assign(socket,
       address: address,
       address_changeset: Address.changeset(),
       earth: earth,
       elevation: elevation,
       from_date: @today,
       to_date: @tomorrow,
       time: @time,
       latitude: latitude,
       longitude: longitude,
       headers: headers,
       rows: rows,
       moon_phase_url: moon_phase_url,
       selected_body: "mars"
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, parse_params(socket, params)}
  end

  defp parse_params(socket, %{"body" => body}) do
    assign(socket, selected_body: body)
  end

  defp parse_params(socket, _params), do: socket

  defp add_class_to_cells(row) do
    %{cells: Enum.map(row.cells, &add_class_to_cell/1)}
  end

  # todo clean up interpolatino
  defp add_class_to_cell(%{position: %{equatorial: %{right_ascension: %{hours: hours}}}} = cell) do
    Map.put(
      cell,
      :class,
      # convert_distance_to_class_values(cell.distance.from_earth.au) <>
      base_cell_class() <>
        " " <>
        assign_random_color()
      # " " <>
      # assign_position(String.to_float(cell.distance.from_earth.au))
      # " " <>
      # assign_ascension(String.to_float(cell.position.equatorial.right_ascension.hours))
    )
    |> Map.put(:container_class, base_container_class())

    # <> assign_rotation(hours))
  end

  defp base_container_class() do
    "relative border-t border-black h-[3rem] m-15"
  end

  defp assign_rotation(asc_hrs) do
    hours = 0..24 |> Enum.to_list()
    degrees = 0..360//15 |> Enum.to_list()
    zipped = Enum.zip(hours, degrees)
    hours_to_degrees = zipped |> Enum.into(Map.new())

    int_asc_hrs = asc_hrs |> String.to_float() |> round
    deg = Map.get(hours_to_degrees, int_asc_hrs)

    "rotate-[#{deg}deg]"
  end

  defp base_cell_class() do
    "text-xs w-[4rem] h-[4rem] rounded-full border border-black text-center flex flex-col place-content-center"
  end

  defp convert_distance_to_class_values(distance) do
    px = String.to_float(distance) * 50
    " top-[#{px}px] left-[#{px}px]"
  end

  defp assign_random_color() do
    colors =
      for color <- ["blue", "orange", "red", "green", "emerald", "lime", "amber"] do
        "bg-#{color}-500"
      end

    Enum.random(colors)
  end

  # todo this will have to be better binned, binning allows for commented TW classes in heex
  defp assign_ascension(ascension) do
    hrs =
      cond do
        ascension < 1 ->
          "1"

        ascension < 5 ->
          "10"

        ascension < 10 ->
          "20"

        ascension < 20 ->
          "30"

        ascension < 50 ->
          "40"

        true ->
          "50"
      end

    "right-[#{hrs}rem]"
  end

  # todo need to dial in the bins
  defp assign_position(distance) do
    space =
      cond do
        distance < 0.1 ->
          "1"

        distance < 1.0 ->
          "10"

        distance < 1.2 ->
          "20"

        distance < 3.0 ->
          "30"

        distance < 5.0 ->
          "40"

        distance < 10.0 ->
          "50"

        distance < 20.0 ->
          "60"

        true ->
          "70"
      end

    "top-[#{space}rem]"
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
       earth: earth,
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

    {:ok, moon_phase_url} =
      Skies.Requests.moon_phase_request(
        %{date: @today, latitude: latitude, longitude: longitude},
        %{type: "portrait-simple"},
        %{"moonStyle" => "sketch", "backgroundStyle" => "stars"}
      )

    rows = Enum.map(rows, &add_class_to_cells/1)

    socket =
      assign(socket,
        address: address,
        earth: earth,
        latitude: latitude,
        longitude: longitude,
        headers: headers,
        rows: rows,
        moon_phase_url: moon_phase_url
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
