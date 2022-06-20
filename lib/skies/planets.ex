defmodule Skies.Planets do
  @moduledoc """
  The Planets context.
  """

  alias Skies.Repo

  alias Skies.Planets.Planet

  def list_planets(params) do
    Skies.Requests.bodies_request(params)
  end
end
