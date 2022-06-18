defmodule Skies.Planets do
  @moduledoc """
  The Planets context.
  """
  @lat 38.253
  @long -85.758
  @elevation 500
  @today Date.utc_today()
  @tomorrow @today |> Date.add(1)
  @time Time.utc_now() |> Time.truncate(:second)

  defp request(url, options \\ []) do
    auth_hash = "Basic #{Application.get_env(:skies, :hash)}" |> IO.inspect(label: "hash")
    headers = [Authorization: auth_hash]

    {:ok, response} = HTTPoison.get(url, headers, options)
  end

  alias Skies.Repo

  alias Skies.Planets.Planet

  @doc """
  Returns the list of planets.

  ## Examples

      iex> list_planets()
      [%Planet{}, ...]

  """
  def list_planets do
    Skies.Requests.bodies_request()
  end

  # @doc """
  # Gets a single planet.

  # Raises `Ecto.NoResultsError` if the Planet does not exist.

  # ## Examples

  #     iex> get_planet!(123)
  #     %Planet{}

  #     iex> get_planet!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_planet!(id), do: Repo.get!(Planet, id)

  # @doc """
  # Creates a planet.

  # ## Examples

  #     iex> create_planet(%{field: value})
  #     {:ok, %Planet{}}

  #     iex> create_planet(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_planet(attrs \\ %{}) do
  #   %Planet{}
  #   |> Planet.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a planet.

  # ## Examples

  #     iex> update_planet(planet, %{field: new_value})
  #     {:ok, %Planet{}}

  #     iex> update_planet(planet, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_planet(%Planet{} = planet, attrs) do
  #   planet
  #   |> Planet.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a planet.

  # ## Examples

  #     iex> delete_planet(planet)
  #     {:ok, %Planet{}}

  #     iex> delete_planet(planet)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_planet(%Planet{} = planet) do
  #   Repo.delete(planet)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking planet changes.

  # ## Examples

  #     iex> change_planet(planet)
  #     %Ecto.Changeset{data: %Planet{}}

  # """
  # def change_planet(%Planet{} = planet, attrs \\ %{}) do
  #   Planet.changeset(planet, attrs)
  # end
end
