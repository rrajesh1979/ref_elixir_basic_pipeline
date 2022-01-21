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
  alias NimbleCSV.RFC4180, as: CSV

  def main(args \\ []) do
    Logger.info("Starting RefElixir.BasicPipeline")
    Logger.info("Arguments: #{args}")

    args
    |> parse_args()
    |> response()
    |> process_eager_complex()
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

  def process_eager_complex(file_path) do
    file_path
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      %{
        request_id: Enum.at(row, 0),
        name: Enum.at(row, 1),
        credit_requested: Enum.at(row, 2),
        requested_date: Enum.at(row, 3),
        location: Enum.at(row, 4)
      }
    end)
    # Credit check with Experian
    |> Enum.map(fn row ->
      response =
        case HTTPoison.get!("https://run.mocky.io/v3/e6113909-57cb-47fe-9cbd-241e6e32b257") do
          %HTTPoison.Response{status_code: 200} ->
            %{
              request_id: row.request_id,
              request_type: "Experian Check",
              status_code: 200
            }

          _ ->
            %{
              request_id: row.request_id,
              request_type: "Experian Check",
              status_code: :error
            }
        end

      Logger.info("Response Experian Check: #{inspect(response)}")
      row
    end)
    # Credit check with Equifax
    |> Enum.map(fn row ->
      response =
        case HTTPoison.get!("https://run.mocky.io/v3/741a50f7-cce9-495b-a094-d4a00c5438a3") do
          %HTTPoison.Response{status_code: 200} ->
            %{
              request_id: row.request_id,
              request_type: "Equifax Check",
              status_code: 200
            }

          _ ->
            %{
              request_id: row.request_id,
              request_type: "Equifax Check",
              status_code: :error
            }
        end

      Logger.info("Response Equifax Check: #{inspect(response)}")
      row
    end)
    # Check for AML
    |> Enum.map(fn row ->
      response =
        case HTTPoison.get!("https://run.mocky.io/v3/41189e78-3d40-4ab4-971c-ce5c2bb266d2") do
          %HTTPoison.Response{status_code: 200} ->
            %{
              request_id: row.request_id,
              request_type: "AML Check",
              status_code: 200
            }

          _ ->
            %{
              request_id: row.request_id,
              request_type: "AML Check",
              status_code: :error
            }
        end

      Logger.info("Response AML Check: #{inspect(response)}")
      row
    end)
    # Check for Fraud
    |> Enum.map(fn row ->
      response =
        case HTTPoison.get!("https://run.mocky.io/v3/a807d47c-8295-4471-acfa-593bcd0bfe27") do
          %HTTPoison.Response{status_code: 200} ->
            %{
              request_id: row.request_id,
              request_type: "Fraud Check",
              status_code: 200
            }

          _ ->
            %{
              request_id: row.request_id,
              request_type: "Fraud Check",
              status_code: :error
            }
        end

      Logger.info("Response Fraud Check: #{inspect(response)}")
      row
    end)
    # Check for Account Balance
    |> Enum.map(fn row ->
      response =
        case HTTPoison.get!("https://run.mocky.io/v3/054783f0-2613-413b-bb99-1f0cfeda49e1") do
          %HTTPoison.Response{status_code: 200} ->
            %{
              request_id: row.request_id,
              request_type: "Account Balance Check",
              status_code: 200
            }

          _ ->
            %{
              request_id: row.request_id,
              request_type: "Account Balance Check",
              status_code: :error
            }
        end

      Logger.info("Response Account Balance Check: #{inspect(response)}")
      row
    end)
  end

  def hello do
    :hello
  end
end
