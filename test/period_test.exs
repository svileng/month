defmodule PeriodTest do
  use ExUnit.Case
  import Month.Sigils

  describe "new/2" do
    test "creates a struct with dates" do
      {:ok, result} = Month.Period.new(~D[2019-01-01], ~D[2019-03-01])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-03]
      assert Enum.count(result.months) == 3

      {:ok, result} = Month.Period.new(~D[2019-01-01], ~D[2019-01-01])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-01]
      assert Enum.count(result.months) == 1
    end

    test "creates a struct with months" do
      {:ok, result} = Month.Period.new(~M[2019-01], ~M[2019-02])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-02]
      assert Enum.count(result.months) == 2

      {:ok, result} = Month.Period.new(~M[2019-01], ~M[2019-01])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-01]
      assert Enum.count(result.months) == 1
    end
  end

  describe "months/2" do
    test "calculates months inclusive" do
      result = Month.Period.months(~M[2018-12], ~M[2019-3])
      assert result == [~M[2018-12], ~M[2019-01], ~M[2019-02], ~M[2019-03]]

      result = Month.Period.months(~M[2018-12], ~M[2019-1])
      assert result == [~M[2018-12], ~M[2019-01]]
    end

    test "works if first month is same as second" do
      result =Month.Period.months(~M[2019-1], ~M[2019-1])
      assert result == [~M[2019-01]]
    end

    test "works if first month is comes after second" do
      result = Month.Period.months(~M[2019-2], ~M[2019-1])
      assert result == [~M[2019-01], ~M[2019-02]]
    end
  end

  describe "within?/2" do
    test "works when both params are ranges" do
      {:ok, a} = Month.Range.new(~M[2019-01], ~M[2019-03])
      {:ok, b} = Month.Range.new(~M[2019-01], ~M[2019-02])
      {:ok, c} = Month.Range.new(~M[2019-02], ~M[2019-04])

      assert Month.Period.within?(a, a)
      assert Month.Period.within?(b, a)
      refute Month.Period.within?(a, b)
      refute Month.Period.within?(c, a)
    end

    test "works when both params are periods" do
      {:ok, a} = Month.Period.new(~M[2019-01], ~M[2019-03])
      {:ok, b} = Month.Period.new(~M[2019-01], ~M[2019-02])
      {:ok, c} = Month.Period.new(~M[2019-02], ~M[2019-04])
      {:ok, d} = Month.Period.new(~M[2019-01], ~M[2019-01])

      assert Month.Period.within?(a, a)
      assert Month.Period.within?(b, a)
      refute Month.Period.within?(a, b)
      refute Month.Period.within?(c, a)
      assert Month.Period.within?(d, d)
    end

    test "works when date is given for a period" do
      {:ok, period} = Month.Period.new(~M[2019-01], ~M[2019-03])

      assert Month.Period.within?(~D[2019-01-15], period)
      assert Month.Period.within?(~D[2019-03-15], period)
      refute Month.Period.within?(~D[2018-03-15], period)
    end
  end

  describe "shift/2" do
    test "shifts periods forward" do
      {:ok, period} = Month.Period.new(~M[2019-01], ~M[2019-03])
      {:ok, period_b} = Month.Period.new(~M[2019-04], ~M[2019-06])

      assert Month.Period.shift(period, 3) == period_b

      {:ok, period} = Month.Period.new(~M[2019-01], ~M[2019-01])
      {:ok, period_b} = Month.Period.new(~M[2019-03], ~M[2019-03])

      assert Month.Period.shift(period, 2) == period_b
    end

    test "shifts periods backwards" do
      {:ok, period} = Month.Period.new(~M[2019-01], ~M[2019-03])
      {:ok, period_b} = Month.Period.new(~M[2018-10], ~M[2018-12])

      assert Month.Period.shift(period, -3) == period_b
    end
  end
end
