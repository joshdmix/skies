defmodule SkiesWeb.PageController do
  use SkiesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
