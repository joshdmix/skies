defmodule SkiesWeb.Live.Components.Body do
  use Phoenix.Component

  def body(
        %{
          distance: distance,
          extra_info: extra_info,
          id: id,
          name: name,
          position: %{constellation: constellation, equatorial: equatorial, horizonal: horizonal}
        } = assigns
      ) do
    ~H"""
      <div>name: <%= name %></div>
        <div>
        km from earth: <%= distance.from_earth.km %>
        </div>
        <div>
          position:
            <div class="pl-5">
              <div class="">constellation: <%= inspect(constellation.name) %></div>
              <div class="">equatorial declination (degrees): <%= equatorial.declination.degrees %></div>
              <div class="">equatorial right ascension (hours): <%= equatorial.right_ascension.hours %></div>
          </div>
        </div>
        <div>
        horizonal:
          <div class="pl-5">
            <div class="">altitude (degrees): <%= horizonal.altitude.degrees %></div>
            <div class="">azimuth (degrees): <%= horizonal.azimuth.degrees %></div>
        </div>
      </div>
    """
  end
end