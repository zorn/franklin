

```
event: %Franklin.Posts.Events.PostCreated{
  published_at: ~U[2022-08-19 23:08:54Z],
  title: "hello",
  uuid: "db64f3ec-0098-4479-b763-0bc7e41598f2"
}
metadata: %{
  application: Franklin.CommandedApplication,
  causation_id: "9fde3b21-787e-4d57-80ec-1252b69d8497",
  correlation_id: "0d791e51-99f0-44dc-ac32-b672a761ad59",
  created_at: ~U[2022-08-19 23:08:54.262740Z],
  event_id: "385d934c-6a3a-499a-b73d-647be6ffd577",
  event_number: 1,
  handler_name: "Posts.Projectors.Post",
  state: nil,
  stream_id: "db64f3ec-0098-4479-b763-0bc7e41598f2",
  stream_version: 1
}
changes: %{
  post: %Franklin.Posts.Projections.Post{
    __meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
    inserted_at: ~N[2022-08-19 23:08:54],
    published_at: ~U[2022-08-19 23:08:54Z],
    title: "hello",
    updated_at: ~N[2022-08-19 23:08:54],
    uuid: "db64f3ec-0098-4479-b763-0bc7e41598f2"
  },
  projection_version: %Franklin.Posts.Projectors.Post.ProjectionVersion{
    __meta__: #Ecto.Schema.Metadata<:loaded, "projection_versions">,
    inserted_at: nil,
    last_seen_event_number: 1,
    projection_name: "Posts.Projectors.Post",
    updated_at: ~N[2022-08-19 23:08:54.295000]
  },
  verify_projection_version: %{
    version: %Franklin.Posts.Projectors.Post.ProjectionVersion{
      __meta__: #Ecto.Schema.Metadata<:loaded, "projection_versions">,
      inserted_at: ~N[2022-08-19 23:08:54.293851],
      last_seen_event_number: 0,
      projection_name: "Posts.Projectors.Post",
      updated_at: ~N[2022-08-19 23:08:54.293851]
    }
  }
}
```
