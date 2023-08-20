defmodule MojodojoWeb.Router do
  use MojodojoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MojodojoWeb.AuthPlug
  end

  scope "/api", MojodojoWeb do
    pipe_through :api

    get "/v1/flux", API.Manager, :flux_get
    post "/v1/flux", API.Manager, :flux_post
  end
end
