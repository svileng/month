defmodule Month.Range do
  @moduledoc """
  Represents a range of months.

      iex> range = Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, #Month.Range<~M[2019-01], ~M[2019-03]>}
      iex> range.months
      [~M[2019-01], ~M[2019-02], ~M[2019-03]]

  The `months` field contains all months within the range, inclusive.
  """

  import Month.Utils
  alias Month.Period

  @type t :: %Month.Range{
          start: Month.t(),
          end: Month.t(),
          months: list(Month.t())
        }

  @required_fields [
    :start,
    :end,
    :months
  ]

  @enforce_keys @required_fields
  defstruct @required_fields

  @doc """
  Creates a new `Month.Range` using given `Month`s as a start and an end.

  ## Examples

      iex> Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, #Month.Range<~M[2019-01], ~M[2019-03]>}
  """
  @spec new(Date.t(), Date.t()) :: {:ok, Month.Range.t()} | {:error, String.t()}
  @spec new(Month.t(), Month.t()) :: {:ok, Month.Range.t()} | {:error, String.t()}
  def new(%Date{month: first_month, year: first_year}, %Date{month: last_month, year: last_year}) do
    with {:ok, first} <- Month.new(first_year, first_month),
         {:ok, last} <- Month.new(last_year, last_month) do
      new(first, last)
    end
  end

  def new(%Month{} = first, %Month{} = last) do
    if Month.compare(first, last) == :lt do
      result = %Month.Range{
        start: first,
        end: last,
        months: Period.months(first, last)
      }

      {:ok, result}
    else
      {:error, "invalid_range"}
    end
  end

  @doc """
  Sames as `new/2` but returs either result or raises an exception.
  """
  @spec new!(Date.t(), Date.t()) :: Month.Range.t()
  @spec new!(Month.t(), Month.t()) :: Month.Range.t()
  def new!(%Date{year: first_year, month: first_month}, %Date{year: last_year, month: last_month}) do
    first = Month.new!(first_year, first_month)
    last = Month.new!(last_year, last_month)
    unwrap_or_raise(new(first, last))
  end

  def new!(%Month{} = first, %Month{} = last) do
    unwrap_or_raise(new(first, last))
  end

  defimpl Inspect do
    def inspect(month_range, _opts) do
      "#Month.Range<#{inspect(month_range.start)}, #{inspect(month_range.end)}>"
    end
  end
end
