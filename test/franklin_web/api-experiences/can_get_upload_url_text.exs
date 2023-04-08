defmodule FranklinWeb.ApiExperiences.CanGetUploadUrlTest do
  use FranklinWeb.ConnCase

  @query """
  mutation {
    generateUploadUrl(filename: "demo.jpg") {
      url
    }
  }
  """
  test "returns an presigned url for the given filename", ~M{conn} do
    conn = post(conn, "/api", query: @query)
    assert response = json_response(conn, 200)
    %{"data" => %{"generateUploadUrl" => %{"url" => url}}} = response

    assert String.starts_with?(
             url,
             "http://localhost:9000/franklin-media/demo.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256"
           )
  end
end
