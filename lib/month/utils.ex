defmodule Month.Utils do
  @moduledoc false

  def unwrap_or_raise({:ok, result}), do: result
  def unwrap_or_raise({:error, msg}), do: raise(ArgumentError, message: msg)
end
