defmodule MojodojoWeb.Router do
  use MojodojoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MojodojoWeb.AuthPlug
  end

  scope "/api", MojodojoWeb do
    pipe_through :api

    get "/v1/state", API.Manager, :state
    post "/v1/toggle_light", API.Manager, :toggle_light
  end
end
