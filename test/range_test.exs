defmodule RangeTest do
  use ExUnit.Case
  import Month.Sigils

  describe "new/2" do
    test "creates a struct with dates" do
      {:ok, result} = Month.Range.new(~D[2019-01-01], ~D[2019-03-01])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-03]
      assert Enum.count(result.months) == 3
    end

    test "creates a struct with months" do
      {:ok, result} = Month.Range.new(~M[2019-01], ~M[2019-02])
      assert result.start == ~M[2019-01]
      assert result.end == ~M[2019-02]
      assert Enum.count(result.months) == 2
    end
  end
end
