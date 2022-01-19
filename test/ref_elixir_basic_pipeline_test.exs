defmodule RefElixirBasicPipelineTest do
  use ExUnit.Case
  doctest RefElixirBasicPipeline

  test "greets the world" do
    assert RefElixirBasicPipeline.hello() == :world
  end
end
