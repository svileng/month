defmodule Month.Sigils do
  @moduledoc """
  Contains sigils only, for convenience.
  """

  @doc """
  Constructs a `%Month{}` struct using the `~M` sigil.

  Uses `new!/2` behind the scenes so will throw an exception
  on invalid input.

  ## Examples

      iex> import Month
      Month
      iex> month = ~M[2019-03]
      ~M[2019-03]
      iex> Month.add(month, 3)
      {:ok, ~M[2019-06]}

  """
  def sigil_M(string, []) do
    [year, month] =
      string
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    Month.new!(year, month)
  end
end
