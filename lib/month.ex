defmodule Month do
  @moduledoc """
  A data structure and a set of methods for those who work exclusively
  with months and month ranges.

  Please check the documentation for `Month` as well as `Month.Range`.

  ### Using the ~M sigil

  To use the `~M` sigil, please import `Month.Sigils` like so:

      defmodule SomeModule do
        import Month.Sigils
        # ...
      end

  Then you can do

      date = ~M[2000-01]

  ### Examples

      iex> ~M[2019-03].month
      3

      iex> ~M[2019-03].year
      2019

      iex> range = Month.Range.new!(~M[2019-01], ~M[2019-03])
      #Month.Range<~M[2019-01], ~M[2019-03]>

      iex> range.months
      [~M[2019-01], ~M[2019-02], ~M[2019-03]]

  """
  import Month.Utils

  @type t :: %Month{
          month: integer,
          year: integer,
          first_date: Date.t(),
          last_date: Date.t()
        }

  @required_fields [
    :month,
    :year,
    :first_date,
    :last_date
  ]

  @enforce_keys @required_fields
  defstruct @required_fields

  @doc """
  Creates a new `Month` struct, using either year/month or another
  struct that has `year` and `month` fields, such as `Date` or `DateTime`.
  """
  @spec new(map) :: {:ok, Month.t()} | {:error, String.t()}
  @spec new(integer, integer) :: {:ok, Month.t()} | {:error, String.t()}
  def new(%{month: month, year: year}) do
    new(year, month)
  end

  def new(year, month) when is_integer(year) and is_integer(month) do
    if :calendar.valid_date(year, month, 1) do
      {:ok, date} = Date.new(year, month, 1)
      dates = dates(date)

      result = %Month{
        month: month,
        year: year,
        first_date: List.first(dates),
        last_date: List.last(dates)
      }

      {:ok, result}
    else
      {:error, "invalid_date"}
    end
  end

  @doc """
  Sames as `new/2` but returns result or throws.
  """
  @spec new!(map) :: Month.t()
  @spec new!(integer, integer) :: Month.t()
  def new!(%{month: month, year: year}) do
    unwrap_or_raise(new(year, month))
  end

  def new!(year, month) do
    unwrap_or_raise(new(year, month))
  end

  @doc """
  Returns list of dates in a month.
  """
  @spec dates(Date.t()) :: list(Date.t())
  @spec dates(Month.t()) :: list(Date.t())
  def dates(%Date{} = date) do
    Enum.map(1..Date.days_in_month(date), fn day ->
      {:ok, date} = Date.new(date.year, date.month, day)
      date
    end)
  end

  def dates(%Month{} = month) do
    Enum.map(1..month.last_date.day, fn day ->
      {:ok, date} = Date.new(month.year, month.month, day)
      date
    end)
  end

  @doc """
  Compares two months and returns if first one is greater (after),
  equal or less (before) the second one.

  ## Examples

      iex> Month.compare(~M[2020-03], ~M[2019-12])
      :gt
  """
  @spec compare(Month.t(), Month.t()) :: :eq | :lt | :gt
  def compare(%Month{} = a, %Month{} = b) do
    Date.compare(a.first_date, b.first_date)
  end

  @doc """
  Adds or subtracts months from given month.

  You can pass a negative number of months to subtract.

  ## Examples

      iex> {:ok, month} = Month.new(2019, 3)
      {:ok, ~M[2019-03]}
      iex> Month.add(month, 3)
      {:ok, ~M[2019-06]}
  """
  @spec add(Month.t(), integer) :: {:ok, Month.t()} | {:error, String.t()}
  def add(%Month{} = month, num_months) when num_months != 0 do
    increment = if num_months > 0, do: 1, else: -1

    [{next_year, next_month}] =
      {month.year, month.month, num_months}
      |> Stream.unfold(fn
        {_, _, 0} ->
          nil

        {year, month, num_months_to_go} ->
          {next_year, next_month} =
            case month + increment do
              13 ->
                {year + increment, 1}

              0 ->
                {year + increment, 12}

              month ->
                {year, month}
            end

          {{next_year, next_month}, {next_year, next_month, num_months_to_go - increment}}
      end)
      |> Enum.take(-1)

    new(next_year, next_month)
  end

  def add(%Month{} = month, num_months) when num_months == 0, do: {:ok, month}

  @doc """
  Same as `add/2` but returns result or throws.
  """
  @spec add!(Month.t(), integer) :: Month.t()
  def add!(%Month{} = month, num_months) when num_months != 0 do
    unwrap_or_raise(add(month, num_months))
  end

  def add!(%Month{} = month, num_months) when num_months == 0, do: month

  @doc """
  Subtracts the given positive number of months from the month.

  Same as `add/2` when you give it a negative number of months.
  """
  def subtract(%Month{} = month, num_months) when num_months > 0 do
    add(month, -num_months)
  end

  def subtract(_, _), do: {:error, "invalid_argument"}

  @doc """
  Same as `subtract/2` but either returns result or throws.
  """
  @spec subtract!(Month.t(), integer) :: Month.t()
  def subtract!(%Month{} = month, num_months) when num_months > 0 do
    add!(month, -num_months)
  end

  def subtract!(_, _), do: raise(ArgumentError, message: "invalid_argument")

  def utc_now(), do: now("Etc/UTC")

  def utc_now!(), do: now!("Etc/UTC")

  def now(tz) do
    {:ok, now} = DateTime.now(tz)
    new(now)
  end

  def now!(tz) do
    {:ok, now} = DateTime.now(tz)
    new!(now)
  end

  defimpl Inspect do
    def inspect(month, _opts) do
      "~M[#{month.year}-#{format_month(month.month)}]"
    end

    defp format_month(day) when day > 0 and day < 10, do: "0#{day}"
    defp format_month(day), do: "#{day}"
  end
end
