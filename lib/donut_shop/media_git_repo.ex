defmodule DonutShop.MediaGitRepo do
  alias DonutShop.{Git, Utils}

  defmodule Env do
    for key <- [:remote, :path, :lfs_endpoint, :lfs_username, :lfs_password] do
      def unquote(key)() do
        Application.fetch_env!(:donut_shop, DonutShop.MediaGitRepo)
        |> Keyword.fetch!(unquote(key))
      end
    end
  end

  alias __MODULE__.Env

  def clone() do
    Git.clone(Env.remote(), Env.path())
    Git.user_config(Env.path())
  end

  def add_file(tmp_path, subdir, content_type) do
    Git.pull(Env.path())
    {sha, size} = get_file_data(tmp_path)

    {:upload, {href, headers}, verify} = make_batch_request(sha, size)
    do_upload(tmp_path, href, headers, content_type, size)
    maybe_verify(verify, sha, size)
    update_repo(sha, size, subdir, content_type)
  end

  defp extension("image/jpeg"), do: "jpeg"

  def update_repo(sha, size, subdir, content_type) do
    pointer = "version https://git-lfs.github.com/spec/v1\noid sha256:#{sha}\nsize #{size}\n"
    filepath = Path.join(subdir, sha <> "." <> extension(content_type))
    full_path = Path.join(Env.path(), filepath)
    File.write!(full_path, pointer)
    Git.add(Env.path(), filepath)
    Git.commit(Env.path())
    Git.push(Env.path())
    :ok
  end

  def do_upload(tmp_path, href, headers, content_type, size) do
    headers = [
      {"content-type", content_type},
      {"content-length", Integer.to_string(size)} | headers
    ]

    stream = File.stream!(tmp_path, [], 2048)

    {:ok, _} =
      Finch.build(:put, href, headers, {:stream, stream})
      |> Finch.request(DonutShop.Finch, receive_timeout: 60_000)

    :ok
  end

  def maybe_verify(nil, _, _), do: :ok

  def maybe_verify({href, headers}, sha, size) do
    body = Jason.encode!(%{oid: sha, size: size})

    {:ok, %Finch.Response{status: 200}} =
      Finch.build(:post, href, headers, body) |> Finch.request(DonutShop.Finch)

    :ok
  end

  def get_file_data(path) do
    sha = Utils.file_sha256(path)
    %File.Stat{size: size} = File.stat!(path)
    {sha, size}
  end

  def make_batch_request(sha, size) do
    auth = Base.encode64(Env.lfs_username() <> ":" <> Env.lfs_password())

    headers = [
      {"authorization", "Basic #{auth}"},
      {"accept", "application/vnd.git-lfs+json"},
      {"content-type", "application/vnd.git-lfs+json"}
    ]

    body =
      Jason.encode!(%{operation: :upload, transfers: [:basic], objects: [%{oid: sha, size: size}]})

    {:ok, res} =
      Finch.build(:post, Env.lfs_endpoint(), headers, body) |> Finch.request(DonutShop.Finch)

    %{"transfer" => "basic", "objects" => [object]} = Jason.decode!(res.body)

    if actions = object["actions"] do
      %{"upload" => %{"href" => upload_href} = upload} = actions

      upload_headers =
        if headers = upload["header"] do
          Map.to_list(headers)
        else
          []
        end

      verify =
        if verify = actions["verify"] do
          %{"href" => href} = verify

          if headers = verify["header"] do
            {href, Map.to_list(headers)}
          else
            {href, []}
          end
        else
          nil
        end

      {:upload, {upload_href, upload_headers}, verify}
    else
      :duplicate
    end
  end
end
