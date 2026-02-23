defmodule Month do
  @moduledoc """
  A data structure and a set of methods for those who work exclusively
  with months and month ranges.

  Please check the documentation for `Month` as well as `Month.Period` and
  `Month.Range`, which cover some extra use cases.

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
  Creates a new `Month` struct, using a map that has `year` and `month` fields. Intended to be
  used with `Date` or `DateTime` structs.

  ### Examples

      iex> Month.new(Date.utc_today())
      {:ok, ~M[2019-03]}

      iex> Month.new(DateTime.utc_now())
      {:ok, ~M[2019-03]}

      iex> Month.new(%{year: 2019, month: 3})
      {:ok, ~M[2019-03]}
  """
  @spec new(map) :: {:ok, Month.t()} | {:error, String.t()}
  @spec new(integer, integer) :: {:ok, Month.t()} | {:error, String.t()}
  def new(%{month: month, year: year}) do
    new(year, month)
  end

  @doc """
  Creates a new `Month` struct using given year and month.

  ### Examples

      iex> Month.new(2019, 3)
      {:ok, ~M[2019-03]}
  """
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
  Sames as `new/1` but returns result or throws.
  """
  @spec new!(map) :: Month.t()
  def new!(%{month: month, year: year}) do
    unwrap_or_raise(new(year, month))
  end

  @doc """
  Sames as `new/2` but returns result or throws.
  """
  @spec new!(integer, integer) :: Month.t()
  def new!(year, month) do
    unwrap_or_raise(new(year, month))
  end

  @doc """
  Returns list of dates in a month.

  ### Examples

      iex> Month.dates(~M[2019-02])
      [~D[2019-02-01], ~D[2019-02-02], ~D[2019-02-03], ~D[2019-02-04], ~D[2019-02-05],
       ~D[2019-02-06], ~D[2019-02-07], ~D[2019-02-08], ~D[2019-02-09], ~D[2019-02-10],
       ~D[2019-02-11], ~D[2019-02-12], ~D[2019-02-13], ~D[2019-02-14], ~D[2019-02-15],
       ~D[2019-02-16], ~D[2019-02-17], ~D[2019-02-18], ~D[2019-02-19], ~D[2019-02-20],
       ~D[2019-02-21], ~D[2019-02-22], ~D[2019-02-23], ~D[2019-02-24], ~D[2019-02-25],
       ~D[2019-02-26], ~D[2019-02-27], ~D[2019-02-28]]
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

  ### Examples

      iex> Month.subtract(~M[2019-03], 3)
      {:ok, ~M[2018-12]}
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

  @doc """
  Returns a `%Month{}` representing current month, according to the Etc/UTC timezone.
  """
  def utc_now(), do: now("Etc/UTC")

  @doc """
  Same as `utc_now/0` but returns result directly or throws.
  """
  def utc_now!(), do: now!("Etc/UTC")

  @doc """
  Returns a `%Month{}` representing current month, according to the given timezone.

  This requires Elixir 1.8+ and a configured timezone database (such as `tzdata`).

  ### Examples

      iex> Month.now("America/New_York")
      {:ok, ~M[2019-03]}
  """
  def now(tz) do
    {:ok, now} = DateTime.now(tz)
    new(now)
  end

  @doc """
  Same as `now/1` but returns result directly or throws.
  """
  def now!(tz) do
    {:ok, now} = DateTime.now(tz)
    new!(now)
  end

  @doc """
  Converts given `%Month{}` to a string.

  ### Examples

      iex> Month.to_string(~M[2019-03])
      "2019-03"
  """
  def to_string(%{year: year, month: month}) when month >= 1 and month <= 9 do
    "#{year}-0#{month}"
  end

  def to_string(%{year: year, month: month}) when month >= 10 and month <= 12 do
    "#{year}-#{month}"
  end

  #
  # Protocols
  #
  #

  defimpl String.Chars do
    def to_string(month) do
      Month.to_string(month)
    end
  end

  defimpl Inspect do
    def inspect(month, _opts) do
      "~M[#{month}]"
    end
  end
end
