defmodule FranklinWeb.AdminUserStories.CanCreateAndEditWithArticleEditor do
  @moduledoc """
  Asserts the business rule that an authenticated admin can create or edit an
  article via the article editor and that field value failures work as expected.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  setup %{conn: conn} do
    # Because the article editor is used for both the creation and editing of
    # articles, we'll construct two instances of the live view, allowing us to
    # shape the tests to verify aspects of the form for both its create mode
    # as well as its edit version.

    now = DateTime.utc_now()

    # This will be the article we will edit.
    edit_article_attributes = %{
      title: "edit article title",
      slug: "slug/edit-article-title/",
      body: "edit article body",
      published_at: now
    }

    {:ok, edit_article_id} = Articles.create_article(edit_article_attributes)

    {:ok, edit_article} =
      wait_for_passing(fn ->
        # Because projections are not instant, we need to wait until it is finished.
        assert {:ok,
                %Article{
                  title: "edit article title",
                  slug: "slug/edit-article-title/",
                  body: "edit article body",
                  published_at: ^now
                }} = Articles.fetch_article(edit_article_id)
      end)

    {:ok, create_view, _html} = live(conn, "/admin/articles/editor/new")
    {:ok, edit_view, _html} = live(conn, "/admin/articles/editor/#{edit_article.id}")

    ~M{create_view, edit_view, edit_article}
  end

  test "creation succeeds with all required form fields", ~M{create_view} do
    valid_params = %{
      title: "A valid new article title.",
      slug: "slug/a-valid-new-article-title",
      slug_autogenerate: false,
      body: "A valid new article body."
    }

    create_view
    |> form("#new_article", article_form: valid_params)
    |> render_submit()
    |> dbg()

    # Because the data projection can take time, we need to wait_for_passing.
    article =
      wait_for_passing(fn ->
        # FIXME: This is a shit test because I'm using `list_articles/0` but atm I don't
        # have the `id` of the created article to use in `fetch_article/1`. Once we
        # change to redirecting to a view page we can sniff the id from the url
        # being redirected to.
        assert Enum.find(Articles.list_articles(), nil, fn article ->
                 match?(
                   %Article{
                     title: "A valid new article title.",
                     body: "A valid new article body.",
                     slug: "slug/a-valid-new-article-title",
                     published_at: %DateTime{}
                   },
                   article
                 )
               end)
      end)

    redirect_path = "/admin/articles/#{article.id}"
    assert {^redirect_path, _flash} = assert_redirect(create_view)
  end

  test "empty slug field values will get a new slug value based on the title", ~M{create_view} do
    valid_params = %{
      title: "Cookies are good!",
      slug: "",
      slug_autogenerate: true,
      body: "We like cookies."
    }

    create_view
    |> form("#new_article", article_form: valid_params)
    |> render_submit()

    # Because the data projection can take time, we need to wait_for_passing.
    article =
      wait_for_passing(fn ->
        # FIXME: This is a shit test because I'm using `list_articles/0` but atm I don't
        # have the `id` of the created article to use in `get_article/1`. Once we
        # change to redirecting to a view page we can sniff the id from the url
        # being redirected to.
        assert Enum.find(Articles.list_articles(), nil, fn article ->
                 match?(
                   %Article{
                     title: "Cookies are good!",
                     body: "We like cookies.",
                     slug: _slug,
                     published_at: %DateTime{}
                   },
                   article
                 )
               end)
      end)

    assert String.ends_with?(article.slug, "/cookies-are-good/")
    redirect_path = "/admin/articles/#{article.id}"
    assert {^redirect_path, _flash} = assert_redirect(create_view)
  end

  test "editing succeeds with all required form fields changed", ~M{edit_view, edit_article} do
    edited_title = "#{edit_article.title} was edited."
    edited_body = "#{edit_article.body} was edited."
    edited_slug = "#{edit_article.slug}-was-edited/"
    edited_published_at = DateTime.add(edit_article.published_at, -5, :day)

    edited_params = %{
      title: edited_title,
      slug: edited_slug,
      body: edited_body,
      published_at: DateTime.to_iso8601(edited_published_at)
    }

    edit_view
    |> form("#new_article", article_form: edited_params)
    |> render_submit()

    # Because the data projection can take time, we need to wait_for_passing.
    wait_for_passing(fn ->
      assert {:ok,
              %Article{
                title: ^edited_title,
                slug: ^edited_slug,
                body: ^edited_body,
                published_at: ^edited_published_at
              }} = Articles.fetch_article(edit_article.id)
    end)

    redirect_path = "/admin/articles/#{edit_article.id}"
    assert {^redirect_path, _flash} = assert_redirect(edit_view)
  end

  describe "verify title input failure responses" do
    test "fails without a required title value", ~M{create_view, edit_view} do
      for view <- [create_view, edit_view] do
        view
        |> form("#new_article", article_form: %{title: ""})
        |> render_submit()

        assert has_element?(view, error_feedback_query(:title), "can't be blank")
      end
    end

    test "fails with a title more than 255 max characters", ~M{create_view, edit_view} do
      invalid_title = Faker.Lorem.characters(255 + 1) |> to_string()

      for view <- [create_view, edit_view] do
        view
        |> form("#new_article", article_form: %{title: invalid_title})
        |> render_submit()

        # FIXME: The new component system seems to fail at showing the number
        # value in place of the `%{count}` token. Updating the test for the
        # moment to accept the token in the message. Not a big deal since this
        # is internal facing.
        # https://github.com/ArthurClemens/primer_live/issues/36
        assert has_element?(
                 view,
                 error_feedback_query(:title),
                 "should be at most %{count} character(s)"
               )
      end
    end
  end

  describe "verify slug input failure responses" do
    test "slugs can not have any character outside of alphanumeric and dashes",
         ~M{create_view, edit_view} do
      invalid_slug = "!?invalid slug?!"

      for view <- [create_view, edit_view] do
        view
        |> form("#new_article",
          article_form: %{
            slug: invalid_slug,
            slug_autogenerate: false
          }
        )
        |> render_submit()

        assert has_element?(
                 view,
                 error_feedback_query(:slug),
                 "has invalid format"
               )
      end
    end
  end

  describe "verify published_at input failure responses" do
    test "fails without a date-specific string published_at value", ~M{create_view, edit_view} do
      for view <- [create_view, edit_view] do
        view
        |> form("#new_article", article_form: %{published_at: "not a date"})
        |> render_submit()

        assert has_element?(view, error_feedback_query(:published_at), "is invalid")
      end
    end
  end

  describe "verify body input failure responses" do
    test "fails without a required body value", ~M{create_view, edit_view} do
      for view <- [create_view, edit_view] do
        view
        |> form("#new_article", article_form: %{body: ""})
        |> render_submit()

        assert has_element?(view, error_feedback_query(:body), "can't be blank")
      end
    end

    test "fails with a body value of more than 30_000 characters", ~M{create_view, edit_view} do
      invalid_body = Faker.Lorem.characters(30_000 + 1) |> to_string()

      for view <- [create_view, edit_view] do
        view
        |> form("#new_article", article_form: %{body: invalid_body})
        |> render_submit()

        assert has_element?(
                 view,
                 error_feedback_query(:body),
                 "should be at most %{count} character(s)"
               )
      end
    end
  end

  defp error_feedback_query(field_name) do
    "div[phx-feedback-for='article_form[#{field_name}]']"
  end
end
