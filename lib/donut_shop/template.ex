defmodule DonutShop.Template do
  require EEx
  import Ecto.Query
  use Phoenix.Component
  alias DonutShop.{Post, Repo}

  @output_dir Path.join(:code.priv_dir(:donut_shop), "output")
  @static_dir Path.join(:code.priv_dir(:donut_shop), "static")

  slot :inner_block, required: true

  defp html(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <%= render_slot(@inner_block) %>
    </html>
    """
  end

  attr :title, :string, required: true

  defp head(assigns) do
    ~H"""
    <head>
      <link rel="stylesheet" href="/css/style.css" />
      <meta charset="utf-8" />
      <meta name="viewport" content="width = device-width" />
      <title><%= @title %></title>
    </head>
    """
  end

  defp header(assigns) do
    ~H"""
    <header>
      <h1>I Am Bismark</h1>
    </header>
    """
  end

  defp footer(assigns) do
    ~H"""
    <footer>
      <ul>
        <li><a href="/about/">About</a></li>
      </ul>
      <div id="about">
        <div id="hcard-Ryan-Johnson" class="h-card">
          <img class="u-photo" alt="avatar" src="/avatar.svg" />
          - Copyright <a class="p-name u-url" rel="author" href="https://iambismark.net/">Ryan Johnson</a>, 2005-<%= current_year() %> -
          <a class="u-email" href="mailto:ryan@iambismark.net">ryan@iambismark.net</a>
        </div>
      </div>
    </footer>
    """
  end

  slot :inner_block, required: true

  defp body(assigns) do
    ~H"""
    <body>
      <div id="container">
        <.header />
        <main>
          <%= render_slot(@inner_block) %>
        </main>
        <.footer />
      </div>
    </body>
    """
  end

  defp permalink(post) do
    slug_id = Post.slug_id(post)
    "/post/#{slug_id}/"
  end

  attr :post, Post, required: true

  defp article(assigns) do
    content_class =
      if assigns.post.title do
        ["e-content"]
      else
        ["e-content", "p-name"]
      end

    assigns = assign(assigns, :content_class, content_class)

    ~H"""
    <article class="h-entry">
      <%= if title = @post.title do %>
        <h2 class="p-name"><%= title %></h2>
      <% end %>
      <div class={@content_class}>
        <p><%= @post.text %></p>
      </div>
      <a class="u-uid u-url" href={permalink(@post)}>
        <time class="dt-published" datetime={DateTime.to_iso8601(@post.created_at) <> "Z"}>
          <%= @post.created_at |> DateTime.to_date() |> Date.to_iso8601() %>
        </time>
      </a>
      <a class="u-author" href="/"></a>
    </article>
    """
  end

  attr :post, Post, required: true

  defp post_page(assigns) do
    ~H"""
    <.html>
      <.head title={(@post.title || "Post") <> "| I Am Bismark"} />
      <.body>
        <.article post={@post} />
      </.body>
    </.html>
    """
  end

  defp archive_counts() do
    Repo.all(
      from(
        p in Post,
        group_by: fragment(~s|STRFTIME('%Y-%m', ?)|, p.created_at),
        select: {fragment(~s|STRFTIME('%Y-%m', ?)|, p.created_at), count(p.id)}
      )
    )
  end

  defp archive_page(assigns) do
    ~H"""
    <.html>
      <.head title="Archive | I Am Bismark" /> j
      <.body>
        <h1>Archive</h1>
        <ul>
          <%= for {date, count} <- archive_counts() do %>
            <li><a {[href: date <> "/"]}><%= date %></a> (<%= count %>)</li>
          <% end %>
        </ul>
      </.body>
    </.html>
    """
  end

  defp archive_months() do
    Repo.all(
      from(
        p in Post,
        distinct: true,
        select: fragment(~s|STRFTIME('%Y-%m', ?)|, p.created_at)
      )
    )
  end

  defp archive_month_posts(month) do
    Repo.all(
      from(
        p in Post,
        where: fragment("STRFTIME('%Y-%m', ?)", p.created_at) == ^month
      )
    )
  end

  attr :month, :string, required: true

  defp archive_month_page(assigns) do
    ~H"""
    <.html>
      <.head title="#{@month} | I Am Bismark" />
      <.body>
        <h1><%= @month %></h1>
        <%= for post <- archive_month_posts(@month) do %>
          <.article post={post} />
        <% end %>
      </.body>
    </.html>
    """
  end

  attr :name, :string, required: true

  defp index(assigns) do
    ~H"""
    <.html>
      <.head title="I Am Bismark" />
      <.body>
        Hello <%= @name %>
      </.body>
    </.html>
    """
  end

  def run() do
    File.mkdir_p!(@output_dir)

    %{name: "Ryan"}
    |> index()
    |> Phoenix.HTML.Safe.to_iodata()
    |> then(fn html ->
      File.write!(Path.join(@output_dir, "index.html"), html)
    end)

    posts_path = Path.join(@output_dir, "post")
    File.mkdir_p!(posts_path)

    Post
    |> Repo.all()
    |> Enum.each(fn post ->
      slug_id = Post.slug_id(post)
      path = Path.join(posts_path, "#{slug_id}")
      File.mkdir_p!(path)

      %{post: post}
      |> post_page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> then(fn html ->
        File.write!(Path.join(path, "index.html"), html)
      end)
    end)

    archive_path = Path.join(@output_dir, "archive")
    File.mkdir_p!(archive_path)

    archive_page(%{})
    |> Phoenix.HTML.Safe.to_iodata()
    |> then(fn html ->
      File.write!(Path.join(archive_path, "index.html"), html)
    end)

    Enum.each(archive_months(), fn month ->
      month_path = Path.join(archive_path, month)
      File.mkdir_p!(month_path)

      archive_month_page(%{month: month})
      |> Phoenix.HTML.Safe.to_iodata()
      |> then(fn html ->
        File.write!(Path.join(month_path, "index.html"), html)
      end)
    end)

    File.cp_r!(@static_dir, @output_dir)
  end

  defp current_year() do
    Date.utc_today().year
  end
end
