defmodule DonutShop.DevServer do
  use Plug.Builder
  plug Plug.Logger

  plug :redirect_index
  plug Plug.Static, at: "/", from: {:donut_shop, "priv/output"}
  plug :not_found

  def redirect_index(%Plug.Conn{path_info: []} = conn, _) do
    %Plug.Conn{conn | path_info: ["index.html"]}
  end

  def redirect_index(conn, _) do
    if String.ends_with?(conn.request_path, "/") do
      %Plug.Conn{conn | path_info: conn.path_info ++ ["index.html"]}
    else
      conn
    end
  end

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end
end
