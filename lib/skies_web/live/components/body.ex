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
      <div class="w-[8rem] h-[8rem] rounded-full border border-black text-center align-middle flex justify-items">
        <div class="m-auto"><%= name %></div>
        <div><%= horizonal.altitude.degrees %></div>
      </div>
    """
  end
end

# <div>
#   position:
#     <div class="pl-5">
#       <div class="">constellation: <%= inspect(constellation.name) %></div>
#       <div class="">equatorial declination (degrees): <%= equatorial.declination.degrees %></div>
#       <div class="">equatorial right ascension (hours): <%= equatorial.right_ascension.hours %></div>
#   </div>
# </div>
# <div>
# horizonal:
#   <div class="pl-5">
#     <div class="">altitude (degrees): <%= horizonal.altitude.degrees %></div>
#     <div class="">azimuth (degrees): <%= horizonal.azimuth.degrees %></div>
# </div>
