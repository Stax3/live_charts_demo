defmodule LiveChartsDemoWeb.DemoLive.Index do
  use LiveChartsDemoWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: tick(1000)

    {:ok,
     socket
     |> assign(adapter: adapter(), templates: templates())
     |> select_template(:bar_chart_simple)}
  end

  def handle_event("select-template", %{"key" => key}, socket) do
    {:noreply, select_template(socket, key)}
  end

  def handle_info(:tick, socket) do
    tick()
    {:noreply, realtime_update(socket.assigns.selected.key, socket)}
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
    {url, data} = Map.pop(data, :url, nil)
    selected = %{key: key, label: label}
    chart = LiveCharts.build(data)
    code = "LiveCharts.build(#{inspect(data, pretty: true, width: 50, charlists: :as_lists)})"

    assign(socket, code: code, chart: chart, url: url, data: [], selected: selected)
  end

  defp templates do
    [
      bar_chart_simple: "Bar Chart",
      line_chart_dynamic: "Line Chart (Dynamic)",
      line_chart_multiseries: "Line Chart (Multi-series)",
      pie_chart: "Pie Chart",
      area_chart_spline: "Area Chart (Spline)",
      area_chart_stacked: "Area Chart (Step, Stacked)",
      heatmap_chart: "Heat Map Chart"
    ]
  end

  defp template_data(:bar_chart_simple) do
    %{
      url: "https://apexcharts.com/docs/chart-types/bar-chart/",
      type: :bar,
      series: [
        %{data: random_series(0, 100, 10)}
      ],
      options: %{
        xaxis: %{
          categories: Enum.to_list(2011..2020)
        },
        colors: ["#23700C"],
        dataLabels: %{
          enabled: false
        }
      }
    }
  end

  defp template_data(:line_chart_dynamic) do
    %{
      url: "https://github.com/Stax3/live_charts?tab=readme-ov-file#example",
      type: :line,
      series: [],
      options: %{
        chart: %{
          toolbar: %{show: false},
          zoom: %{enabled: false},
          animations: %{
            enabled: true,
            easing: "linear"
          }
        },
        stroke: %{
          curve: "smooth"
        },
        xaxis: %{categories: Enum.map(1..5, &"User #{&1}")},
        yaxis: %{min: 0, max: 100},
        dataLabels: %{
          enabled: false
        }
      }
    }
  end

  defp template_data(:line_chart_multiseries) do
    %{
      url: "https://apexcharts.com/docs/chart-types/line-chart/",
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

  defp template_data(:pie_chart) do
    %{
      url: "https://apexcharts.com/docs/chart-types/pie-donut/",
      type: :pie,
      series: random_series(10, 100, 4),
      options: %{
        labels: ~w(Ali Saad Uzair Hassan)
      }
    }
  end

  defp template_data(:area_chart_spline) do
    %{
      url: "https://apexcharts.com/docs/chart-types/area-chart/",
      type: :area,
      series: [
        %{name: "Ali", data: random_series(50, 70, 9) ++ [70, 85, 80]},
        %{name: "Saad", data: random_series(20, 50, 12)}
      ],
      options: %{
        xaxis: %{
          categories: months()
        },
        yaxis: %{
          min: 0,
          max: 100
        },
        dataLabels: %{
          enabled: false
        }
      }
    }
  end

  defp template_data(:area_chart_stacked) do
    %{
      url: "https://apexcharts.com/docs/chart-types/area-chart/",
      type: :area,
      series: [
        %{name: "Ali", data: random_series(40, 80, 12)},
        %{name: "Saad", data: random_series(20, 50, 12)}
      ],
      options: %{
        chart: %{
          stacked: true
        },
        xaxis: %{
          categories: months()
        },
        stroke: %{
          curve: "stepline"
        },
        dataLabels: %{
          enabled: false
        }
      }
    }
  end

  defp template_data(:heatmap_chart) do
    %{
      url: "https://apexcharts.com/docs/chart-types/heatmap-chart/",
      type: :heatmap,
      series:
        Enum.map(months(), fn month ->
          %{
            name: month,
            data:
              Enum.map(1..5, fn i ->
                %{
                  x: to_string(2020 + i),
                  y: random_value(10, 80)
                }
              end)
          }
        end),
      options: %{
        chart: %{
          height: 600
        },
        colors: ["#23700C"],
        dataLabels: %{
          enabled: false
        }
      }
    }
  end

  defp realtime_update(:line_chart_dynamic = key, socket) do
    series = [%{data: random_series(10, 95, 5)}]
    LiveCharts.push_update(socket, to_string(key), series)
  end

  defp realtime_update(_other, socket) do
    socket
  end

  defp tick(duration \\ 750) do
    Process.send_after(self(), :tick, duration)
  end

  defp random_value(min, max) do
    :rand.uniform(max - min) + min
  end

  defp random_series(min, max, count) do
    Enum.map(1..count, fn _ -> random_value(min, max) end)
  end

  defp months do
    ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Nov Dec)
  end
end
