defmodule FranklinWeb.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(FranklinWeb.Schema.ContentTypes)

  alias FranklinWeb.Resolvers

  query do
    @desc "Get a list of the articles."
    field :articles, list_of(:article) do
      resolve(&Resolvers.Content.list_articles/3)
    end

    @desc "Get an article by its id value."
    field :article, :article do
      arg(:id, :id)
      resolve(&Resolvers.Content.fetch_article/3)
    end
  end

  mutation do
    @desc "Given valid user credentials, returns a JWT token"
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/3)
    end

    @desc "Generate a presigned url for uploading a file to S3."
    field :generate_upload_url, :upload_url do
      arg(:filename, non_null(:string))
      resolve(&Resolvers.Content.generate_upload_url/3)
    end

    @desc "Create a new article."
    field :create_article, :create_article_payload do
      arg(:input, non_null(:create_article_input))

      resolve(&Resolvers.Content.create_article/3)
    end
  end

  input_object :create_article_input do
    field(:id, :id)
    field(:title, non_null(:string))
    field(:body, non_null(:string))
    field(:slug, non_null(:string))
    field(:published_at, :datetime)
  end

  object :create_article_payload do
    field(:article_id, :id)
    field(:errors, list_of(:input_error))
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field(:details, non_null(:string))
    field(:message, non_null(:string))
  end

  object :session do
    field(:token, non_null(:string))
    field(:user, non_null(:user))
  end

  object :user do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
  end
end
