defmodule LiveChartsDemoWeb.Router do
  use LiveChartsDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveChartsDemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveChartsDemoWeb do
    pipe_through :browser

    live "/", DemoLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveChartsDemoWeb do
  #   pipe_through :api
  # end
end
