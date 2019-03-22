defmodule Month.Period do
  @moduledoc """
  Represents a period of 1 month or more.

      iex> range = Month.Period.new(~M[2019-01], ~M[2019-03])
      {:ok, #Month.Period<~M[2019-01], ~M[2019-03]>}
      iex> range.months
      [~M[2019-01], ~M[2019-02], ~M[2019-03]]

  The `months` field contains all months within the period, inclusive.

  If you want a guarantee that the period would cover min 2 months or more,
  look at `Month.Range` data structure instead.
  """

  import Month.Utils

  @type t :: %Month.Period{
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
  Creates a new `Month.Period` using given `Month`s as a start and an end.

  ## Examples

      iex> Month.Period.new(~M[2019-01], ~M[2019-03])
      {:ok, #Month.Period<~M[2019-01], ~M[2019-03]>}

      iex> Month.Period.new(~M[2019-03], ~M[2019-01])
      {:ok, #Month.Period<~M[2019-01], ~M[2019-03]>}
  """
  @spec new(Date.t(), Date.t()) :: {:ok, Month.Period.t()} | {:error, String.t()}
  @spec new(Month.t(), Month.t()) :: {:ok, Month.Period.t()} | {:error, String.t()}
  def new(%Date{month: first_month, year: first_year}, %Date{month: last_month, year: last_year}) do
    with {:ok, first} <- Month.new(first_year, first_month),
         {:ok, last} <- Month.new(last_year, last_month) do
      new(first, last)
    end
  end

  def new(%Month{} = first, %Month{} = last) do
    {start_month, end_month} =
      if Month.compare(first, last) in [:lt, :eq] do
        {first, last}
      else
        {last, first}
      end

    result = %Month.Period{
      start: start_month,
      end: end_month,
      months: months(start_month, end_month)
    }

    {:ok, result}
  end

  @doc """
  Sames as `new/2` but returs either result or raises an exception.
  """
  @spec new!(Date.t(), Date.t()) :: Month.Period.t()
  @spec new!(Month.t(), Month.t()) :: Month.Period.t()
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
  def months(%Month{} = from, %Month{} = to) do
    if Month.compare(from, to) == :eq do
      [from]
    else
      {start_month, end_month} =
        if Month.compare(from, to) == :lt do
          {from, to}
        else
          {to, from}
        end

      {:ok, next_month} = Month.add(start_month, 1)

      months =
        next_month
        |> Stream.unfold(fn month ->
          if Month.compare(month, end_month) in [:eq, :gt] do
            nil
          else
            {:ok, next_month} = Month.add(month, 1)
            {month, next_month}
          end
        end)
        |> Enum.to_list()

      [start_month]
      |> Enum.concat(months)
      |> Enum.concat([end_month])
    end
  end

  @doc """
  Checks if the first period is within the second period (inclusive).
  """
  @spec within?(Month.Period.t(), Month.Period.t()) :: boolean
  @spec within?(Month.Range.t(), Month.Range.t()) :: boolean
  @spec within?(Date.t(), Month.Period.t()) :: boolean
  def within?(%Date{} = date, period) do
    found_month =
      Enum.find(period.months, fn month ->
        month.month == date.month && month.year == date.year
      end)

    not is_nil(found_month)
  end

  def within?(%{months: a}, %{months: b}) do
    MapSet.subset?(MapSet.new(a), MapSet.new(b))
  end

  @doc """
  Shifts the given period forwards or backwards by given number of months.
  """
  @spec shift(Month.Period.t(), integer) :: Month.Period.t()
  @spec shift(Month.Range.t(), integer) :: Month.Range.t()
  def shift(period, num_months) do
    shifted_start = Month.add!(period.start, num_months)
    shifted_end = Month.add!(period.end, num_months)
    period.__struct__.new!(shifted_start, shifted_end)
  end

  defimpl Inspect do
    def inspect(month_period, _opts) do
      "#Month.Period<#{inspect(month_period.start)}, #{inspect(month_period.end)}>"
    end
  end
end
