defmodule Franklin.Media do
  def generate_presigned_url(filename) do
    # https://hexdocs.pm/ex_aws_s3/ExAws.S3.html#presigned_url/5
    # expiry_secs = Keyword.get(opts, :expires_in, @default_presigned_url_expiry_secs)

    ExAws.S3.presigned_url(config(), :post, "franklin-media", filename)
  end

  defp config() do
    ExAws.Config.new(:s3)
  end
end
