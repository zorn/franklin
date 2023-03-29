defmodule Franklin.S3Storage do
  @moduledoc """
  Provides low level functions for working with S3 storage.
  """

  @bucket_name "franklin-media"
  @default_expires_in_seconds 60 * 5

  @doc """
  Generates a presigned upload URL to S3 suitable for the given filename.

  This URL is short-lived and expects to be used via an HTTP `PUT` request. This
  URL will point to the bucket defined in the application's configuration.
  """
  @spec generate_presigned_url(String.t()) ::
          {:ok, url :: String.t()} | {:error, reason :: String.t()}
  def generate_presigned_url(filename) do
    opts = [expires_in: @default_expires_in_seconds]
    ExAws.S3.presigned_url(config(), :put, @bucket_name, filename, opts)
  end

  defp config() do
    ExAws.Config.new(:s3)
  end
end
