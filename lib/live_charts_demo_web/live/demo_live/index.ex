defmodule LiveChartsDemoWeb.DemoLive.Index do
  use LiveChartsDemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(adapter: adapter(), templates: templates())
     |> select_template(:simple_bar_chart)}
  end

  def handle_event("select-template", %{"key" => key}, socket) do
    {:noreply, select_template(socket, key)}
  end

  defp adapter do
    supported_adapters = ~w(ApexCharts)

    %{
      value: hd(supported_adapters),
      options: supported_adapters
    }
  end

  defp select_template(socket, key) do
    key =
      if is_atom(key) do
        key
      else
        String.to_atom(key)
      end

    data =
      Map.merge(template_data(key), %{
        id: to_string(key),
        adapter: LiveCharts.Adapter.ApexCharts
      })

    {_key, label} = List.keyfind(templates(), key, 0)
    selected = %{key: key, label: label}
    chart = LiveCharts.build(data)
    code = "LiveCharts.build(#{inspect(data, pretty: true, width: 50, charlists: :as_lists)})"

    assign(socket, code: code, chart: chart, selected: selected)
  end

  defp templates do
    [
      simple_bar_chart: "Simple Bar Chart",
      multi_series_line_chart: "Multi-series Line Chart"
    ]
  end

  defp template_data(:simple_bar_chart) do
    %{
      type: :bar,
      series: [
        %{name: "Sales", data: random_series(0, 100, 10)}
      ],
      options: %{
        xaxis: %{
          categories: Enum.to_list(2011..2020)
        }
      }
    }
  end

  defp template_data(:multi_series_line_chart) do
    %{
      type: :line,
      series: [
        %{name: "Ali", data: random_series(0, 100, 10)},
        %{name: "Saad", data: random_series(0, 100, 10)},
        %{name: "Uzair", data: random_series(0, 100, 10)}
      ],
      options: %{
        xaxis: %{
          categories: Enum.to_list(2011..2020)
        }
      }
    }
  end

  defp random_value(min, max) do
    :rand.uniform(max - min) + min
  end

  defp random_series(min, max, count) do
    Enum.map(1..count, fn _ -> random_value(min, max) end)
  end
end
