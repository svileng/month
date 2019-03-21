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

  @type t :: %Month.Range{
          first: Month.t(),
          last: Month.t(),
          months: list(Month.t())
        }

  @required_fields [
    :first,
    :last,
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
        first: first,
        last: last,
        months: months_for_range!(first, last)
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

  @doc """
  Helper functions that returns the months between the two given
  months, inclusive. Please make sure `from_month` is before `to_month`.
  """
  def months_for_range(%Month{} = from_month, %Month{} = to_month) do
    if Month.compare(from_month, to_month) == :lt do
      {:ok, next_month} = Month.add(from_month, 1)

      months =
        next_month
        |> Stream.unfold(fn month ->
          if Month.compare(month, to_month) in [:eq, :gt] do
            nil
          else
            {:ok, next_month} = Month.add(month, 1)
            {month, next_month}
          end
        end)
        |> Enum.to_list()

      result =
        [from_month]
        |> Enum.concat(months)
        |> Enum.concat([to_month])

      {:ok, result}
    else
      {:error, "invalid_range"}
    end
  end

  @doc """
  Same as `months_for_range/2` but throws an exception or returns result directly.
  """
  def months_for_range!(%Month{} = from_month, %Month{} = to_month) do
    unwrap_or_raise(months_for_range(from_month, to_month))
  end

  @doc """
  Checks if first range (or date) is within second range (inclusive).
  """
  @spec within?(Month.Range.t(), Month.Range.t()) :: boolean
  @spec within?(Date.t(), Month.Range.t()) :: boolean
  def within?(%Month.Range{} = a, %Month.Range{} = b) do
    MapSet.subset?(MapSet.new(a.months), MapSet.new(b.months))
  end

  def within?(%Date{} = date, %Month.Range{} = b) do
    found_month =
      Enum.find(b.months, fn month ->
        month.month == date.month && month.year == date.year
      end)

    not is_nil(found_month)
  end

  def shift(%Month.Range{} = range, num_months) do
    next_first = Month.add!(range.first, num_months)
    next_last = Month.add!(range.last, num_months)
    new!(next_first, next_last)
  end

  defimpl Inspect do
    def inspect(month_range, _opts) do
      "#Month.Range<#{inspect(month_range.first)}, #{inspect(month_range.last)}>"
    end
  end
end
