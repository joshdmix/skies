defmodule SkiesWeb.Live.Components.Body do
  use Phoenix.Component

  def body(
        %{
          class: class,
          distance: distance,
          extra_info: extra_info,
          id: id,
          name: name,
          position: %{constellation: constellation, equatorial: equatorial, horizonal: horizonal}
        } = assigns
      ) do
    ~H"""
    <!--
    "right-[1rem]"
    "right-[10rem]"
    "right-[20rem]"
    "right-[30rem]"
    "right-[40rem]"
    "right-[50rem]"
    "top-[1rem]"
    "top-[10rem]"
    "top-[20rem]"
    "top-[30rem]"
    "top-[40rem]"
    "top-[50rem]"
    "top-[60rem]"
    "top-[70rem]"
    "top-20"
    "top-30"
    "top-40"
    "top-50"
    "top-60"
    "top-70"
    "bg-blue-500"
    "bg-orange-500"
    "bg-red-500"
    "bg-green-500"
    "bg-emerald-500"
    "bg-lime-500"
    "bg-amber-500"
    -->
      <div class={class}>
        <div class=""><%= name %></div>
        <!--
         <div class="">Eq. Dec <%= equatorial.declination.degrees %></div>
         <div class="">Distance from Earth (au) <%= distance.from_earth.au %></div>
        -->
      </div>
    """
  end

  def earth(
        %{
          distance: distance,
          extra_info: extra_info,
          id: id,
          name: name,
          position: %{constellation: constellation, equatorial: equatorial, horizonal: horizonal}
        } = assigns
      ) do
    ~H"""
      <div class="text-xs w-[4rem] h-[4rem] rounded-full border border-black bg-blue-300 text-center flex flex-col place-content-center">
        <div class="">Earth</div>
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
