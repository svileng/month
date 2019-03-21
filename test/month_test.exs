defmodule MonthTest do
  use ExUnit.Case
  import Month.Sigils

  describe "new/1" do
    test "creates a struct with correct params" do
      Enum.each([
        Date.utc_today(),
        DateTime.utc_now(),
        NaiveDateTime.utc_now(),
      ], fn params ->
        assert {:ok, Month.utc_now!()} == Month.new(params)
      end)
    end
  end

  describe "new/2" do
    test "creates a struct with correct params" do
      {:ok, result} = Month.new(2019, 2)

      assert result == ~M[2019-02]
      assert result.month == 2
      assert result.year == 2019
      assert result.first_date == ~D[2019-02-01]
      assert result.last_date == ~D[2019-02-28]
    end

    test "doesn't work with invalid params" do
      Enum.each([
        Month.new(2019, 0),
        Month.new(2019, 23),
        Month.new(2019, -5),
        Month.new(-221, 12),
      ], fn result ->
        assert {:error, "invalid_date"} == result
      end)

      assert_raise FunctionClauseError, fn ->
        Month.new(2019, "a")
      end

      assert_raise FunctionClauseError, fn ->
        Month.new("2019", 1)
      end

      assert_raise FunctionClauseError, fn ->
        Month.new(2019, "a")
      end

      assert_raise FunctionClauseError, fn ->
        Month.new("2019-02")
      end
    end
  end

  describe "add/2" do
    test "adds num of months forward" do
      assert {:ok, ~M[2019-12]} == Month.add(~M[2019-06], 6)
      assert {:ok, ~M[2020-03]} == Month.add(~M[2019-06], 9)
    end

    test "subtracts num of months on negative integer" do
      assert {:ok, ~M[2018-12]} == Month.add(~M[2019-06], -6)
      assert {:ok, ~M[2018-09]} == Month.add(~M[2019-06], -9)
    end

    test "returns same month when num months is zero" do
      assert {:ok, ~M[2018-12]} == Month.add(~M[2018-12], 0)
    end
  end

  describe "compare/2" do
    test "compares months" do
      assert Month.compare(~M[2019-01], ~M[2019-1]) == :eq
      assert Month.compare(~M[2018-01], ~M[2019-1]) == :lt
      assert Month.compare(~M[2019-12], ~M[2019-1]) == :gt
    end
  end
end
