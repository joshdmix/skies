defmodule SkiesWeb.PlanetLiveTest do
  use SkiesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skies.PlanetsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_planet(_) do
    planet = planet_fixture()
    %{planet: planet}
  end

  describe "Index" do
    setup [:create_planet]

    test "lists all planets", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.planet_index_path(conn, :index))

      assert html =~ "Listing Planets"
    end

    test "saves new planet", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.planet_index_path(conn, :index))

      assert index_live |> element("a", "New Planet") |> render_click() =~
               "New Planet"

      assert_patch(index_live, Routes.planet_index_path(conn, :new))

      assert index_live
             |> form("#planet-form", planet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#planet-form", planet: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.planet_index_path(conn, :index))

      assert html =~ "Planet created successfully"
    end

    test "updates planet in listing", %{conn: conn, planet: planet} do
      {:ok, index_live, _html} = live(conn, Routes.planet_index_path(conn, :index))

      assert index_live |> element("#planet-#{planet.id} a", "Edit") |> render_click() =~
               "Edit Planet"

      assert_patch(index_live, Routes.planet_index_path(conn, :edit, planet))

      assert index_live
             |> form("#planet-form", planet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#planet-form", planet: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.planet_index_path(conn, :index))

      assert html =~ "Planet updated successfully"
    end

    test "deletes planet in listing", %{conn: conn, planet: planet} do
      {:ok, index_live, _html} = live(conn, Routes.planet_index_path(conn, :index))

      assert index_live |> element("#planet-#{planet.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#planet-#{planet.id}")
    end
  end

  describe "Show" do
    setup [:create_planet]

    test "displays planet", %{conn: conn, planet: planet} do
      {:ok, _show_live, html} = live(conn, Routes.planet_show_path(conn, :show, planet))

      assert html =~ "Show Planet"
    end

    test "updates planet within modal", %{conn: conn, planet: planet} do
      {:ok, show_live, _html} = live(conn, Routes.planet_show_path(conn, :show, planet))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Planet"

      assert_patch(show_live, Routes.planet_show_path(conn, :edit, planet))

      assert show_live
             |> form("#planet-form", planet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#planet-form", planet: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.planet_show_path(conn, :show, planet))

      assert html =~ "Planet updated successfully"
    end
  end
end
