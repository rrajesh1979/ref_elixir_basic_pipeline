defmodule RefElixir.BasicPipelineTest do
  use ExUnit.Case
  doctest RefElixir.BasicPipeline

  test "greets the world" do
    assert RefElixir.BasicPipeline.hello() == :hello
  end
end
