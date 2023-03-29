# S3 Will Not Enforce File Constraints

While the default Phoenix LiveView upload documentation constructs a POST request, so that S3 is sent the configured constraints of the upload ()

**Status:** Closed on March 20, 2023.

## Problem Context

The [Direct to S3 documentation][1] provided inside of LiveView uses a self-contained `SimpleS3Upload` to construct a multipart form POST request. It does this so that certain file constraints that you configured with [`allow_upload/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#allow_upload/3) are honored by S3.

While this is a more complete implementation, for the current needs of Franklin and to keep things simple to start, we did not follow this pattern. 

[1]: https://hexdocs.pm/phoenix_live_view/uploads-external.html#direct-to-s3

## Decision Made

For presigned upload URLs we are using a more simple PUT style and including a more limited set of arguments as URL parameters.

## Consequences & Tradeoffs

* This does mean that S3 will not inforce any rules or limitations due to file type or size.
* Considering the use case is just us (admins of the site) and presigned upload urls will not be generated for the public we do not feel this will be a problem.
* We can come back in future work and change this to POST if needed without any big impact.
