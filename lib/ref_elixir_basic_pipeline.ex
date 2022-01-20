defmodule RefElixir.BasicPipeline do
  @moduledoc """
  Basic data processing pipeline.
  Eagerly loads data from the source files.
  Uses basic Elixir pipeline to process data.

  synopsis:
    Process credit requests provided as a feed file.
  usage:
    $ ./ref_elixir_basic_pipeline {options} arg1 arg2 ...
  options:
    --file        Feed file path or directory (required)
  """

  require Logger

  def main(args \\ []) do
    args
    |> parse_args()
    |> response()
    |> process()
  end

  defp parse_args(args) do
    {opts, file_path, _} =
      args
      |> OptionParser.parse(switches: [file: :boolean])

    {opts, List.to_string(file_path)}
  end

  defp response({opts, file_path}) do
    case opts[:file] do
      true ->
        Logger.info("File path: #{inspect(file_path)}")
        file_path

      _ ->
        Logger.error("
        File path is not specified
        usage:
          ./ref_elixir_basic_pipeline {options} arg1 arg2 ...
        ")
        raise "Error"
    end
  end

  def process(file_path) do
    File.read!(file_path)
  end

  def hello do
    :hello
  end
end
