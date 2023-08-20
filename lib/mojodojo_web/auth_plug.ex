defmodule MojodojoWeb.AuthPlug do
  import Plug.Conn

  require Logger

  @api_key Application.compile_env(:mojodojo, :api_key)

  def init(opts), do: opts

  def call(conn, _opts) do
    Logger.info(conn)

    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case verify_token(token) do
          {:ok, _} ->
            conn

          {:error, reason} ->
            conn
            |> send_resp(401, reason)
            |> halt()
        end

      _ ->
        conn
        |> send_resp(401, "Missing or invalid authorization header")
        |> halt()
    end
  end

  defp verify_token(token) do
    # Replace with your actual token verification logic
    case token do
      @api_key -> {:ok, ""}
      _ -> {:error, "Invalid token"}
    end
  end
end
