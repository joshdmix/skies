defmodule Skies.PlanetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skies.Planets` context.
  """

  @doc """
  Generate a planet.
  """
  def planet_fixture(attrs \\ %{}) do
    {:ok, planet} =
      attrs
      |> Enum.into(%{})
      |> Skies.Planets.create_planet()

    planet
  end
end
