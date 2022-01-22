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

  require Application
  @experian_endpoint Application.compile_env(:ref_elixir_basic_pipeline, :experian_endpoint)
  @equifax_endpoint Application.compile_env(:ref_elixir_basic_pipeline, :equifax_endpoint)
  @aml_check_endpoint Application.compile_env(:ref_elixir_basic_pipeline, :aml_check_endpoint)
  @fraud_check_endpoint Application.compile_env(:ref_elixir_basic_pipeline, :fraud_check_endpoint)
  @account_balance_endpoint Application.compile_env(
                              :ref_elixir_basic_pipeline,
                              :account_balance_endpoint
                            )

  def main(args \\ []) do
    Logger.info("Starting RefElixir.BasicPipeline")
    Logger.info("Arguments: #{args}")

    args
    |> parse_args()
    |> response()
    |> process_eager()
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

  def process_eager(file_path) do
    read_file(file_path)
    |> parse_rows
    |> Enum.map(&print_record/1)
    |> Enum.map(&experian_check/1)
    |> Enum.map(&equifax_check/1)
    |> Enum.map(&aml_check/1)
    |> Enum.map(&fraud_check/1)
    |> Enum.map(&account_balance_check/1)
    |> Enum.map(&credit_decision/1)
  end

  def read_file(file_path) do
    file_path
    |> File.read!()
  end

  def parse_rows(row) do
    row
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      %{
        request_id: Enum.at(row, 0),
        name: Enum.at(row, 1),
        credit_requested: Enum.at(row, 2),
        requested_date: Enum.at(row, 3),
        location: Enum.at(row, 4),
        status: "NEW_REQUEST",
        activity_log: ["REQUEST_CREATED"]
      }
    end)
  end

  def print_record(record) do
    Logger.info("
      request_id: #{record[:request_id]}
      name: #{record[:name]}
      credit_requested: #{record[:credit_requested]}
      requested_date: #{record[:requested_date]}
      location: #{record[:location]}")
    record
  end

  def experian_check(request) do
    Logger.info("Request for Experian Check: #{inspect(request)}")

    response =
      case HTTPoison.get!(@experian_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Experian Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Experian Check",
            status_code: :error
          }
      end

    Logger.info("Response Experian Check: #{inspect(response)}")

    request_processed = %{
      request
      | status: "EXPERIAN_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["EXPERIAN_CHECK"])
    }

    request_processed
  end

  def equifax_check(request) do
    Logger.info("Request for Equifax Check: #{inspect(request)}")

    response =
      case HTTPoison.get!(@equifax_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Equifax Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Equifax Check",
            status_code: :error
          }
      end

    Logger.info("Response from Equifax Check: #{inspect(response)}")

    request_processed = %{
      request
      | status: "EQUIFAX_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["EQUIFAX_CHECK"])
    }

    request_processed
  end

  def aml_check(request) do
    Logger.info("Request for AML Check: #{inspect(request)}")

    response =
      case HTTPoison.get!(@aml_check_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "AML Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "AML Check",
            status_code: :error
          }
      end

    Logger.info("Response from AML Check: #{inspect(response)}")

    request_processed = %{
      request
      | status: "AML_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["AML_CHECK"])
    }

    request_processed
  end

  def fraud_check(request) do
    Logger.info("Request for Fraud Check: #{inspect(request)}")

    response =
      case HTTPoison.get!(@fraud_check_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Fraud Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Fraud Check",
            status_code: :error
          }
      end

    Logger.info("Response from Fraud Check: #{inspect(response)}")

    request_processed = %{
      request
      | status: "FRAUD_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["FRAUD_CHECK"])
    }

    request_processed
  end

  def account_balance_check(request) do
    Logger.info("Request for Account Balance Check: #{inspect(request)}")

    response =
      case HTTPoison.get!(@account_balance_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Account Balance Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Account Balance Check",
            status_code: :error
          }
      end

    Logger.info("Response from Account Balance Check: #{inspect(response)}")

    request_processed = %{
      request
      | status: "ACCOUNT_BALANCE_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["ACCOUNT_BALANCE_CHECK"])
    }

    request_processed
  end

  def credit_decision(request) do
    Logger.info("Final decision on credit request: #{inspect(request)}")

    final_decision =
      case request.status do
        "ACCOUNT_BALANCE_CHECK_DONE" ->
          "APPROVED"

        _ ->
          "REJECTED"
      end

    request_processed = %{
      request
      | status: final_decision,
        activity_log: Enum.concat(request.activity_log, ["CREDIT_DECISION"])
    }

    request_processed
  end

  def hello do
    :hello
  end
end
