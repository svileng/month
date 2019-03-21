defmodule RangeTest do
  use ExUnit.Case
  import Month.Sigils

  describe "new/2" do
    test "creates a struct with dates" do
      {:ok, result} = Month.Range.new(~D[2019-01-01], ~D[2019-03-01])
      assert result.first == ~M[2019-01]
      assert result.last == ~M[2019-03]
      assert Enum.count(result.months) == 3
    end

    test "creates a struct with months" do
      {:ok, result} = Month.Range.new(~M[2019-01], ~M[2019-02])
      assert result.first == ~M[2019-01]
      assert result.last == ~M[2019-02]
      assert Enum.count(result.months) == 2
    end
  end

  describe "months_for_range/2" do
    test "calculates months inclusive" do
      {:ok, result} = Month.Range.months_for_range(~M[2018-12], ~M[2019-3])
      assert result == [~M[2018-12], ~M[2019-01], ~M[2019-02], ~M[2019-03]]

      {:ok, result} = Month.Range.months_for_range(~M[2018-12], ~M[2019-1])
      assert result == [~M[2018-12], ~M[2019-01]]
    end

    test "reuturns error if first month is same or ahead of last" do
      Enum.each(
        [
          Month.Range.months_for_range(~M[2019-1], ~M[2019-1]),
          Month.Range.months_for_range(~M[2019-1], ~M[2018-1])
        ],
        fn result ->
          assert result == {:error, "invalid_range"}
        end
      )
    end
  end

  describe "within?/2" do
    test "works when both params are ranges" do
      {:ok, a} = Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, b} = Month.Range.new(~M[2019-01], ~M[2019-02])
      {:ok, c} = Month.Range.new(~M[2019-02], ~M[2019-04])

      assert Month.Range.within?(a, a)
      assert Month.Range.within?(b, a)
      refute Month.Range.within?(a, b)
      refute Month.Range.within?(c, a)
    end

    test "works when date is given for a range" do
      {:ok, range} = Month.Range.new(~M[2019-01], ~M[2019-03])

      assert Month.Range.within?(~D[2019-01-15], range)
      assert Month.Range.within?(~D[2019-03-15], range)
      refute Month.Range.within?(~D[2018-03-15], range)
    end
  end

  describe "shift/2" do
    test "works shifting forward" do
      {:ok, range} = Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, range_b} = Month.Range.new(~M[2019-04], ~M[2019-06])

      assert Month.Range.shift(range, 3) == range_b
    end

    test "works shifting backwards" do
      {:ok, range} = Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, range_b} = Month.Range.new(~M[2018-10], ~M[2018-12])

      assert Month.Range.shift(range, -3) == range_b
    end
  end
end
