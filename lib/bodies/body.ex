defmodule Skies.Bodies.Body do
  defstruct date: :string,
            distance: :map,
            id: :string,
            name: :string,
            position: :map,
            extra_info: :map
end
