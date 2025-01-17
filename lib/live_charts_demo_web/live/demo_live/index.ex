defmodule LiveChartsDemoWeb.DemoLive.Index do
  use LiveChartsDemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
