const round = (d, places = 2) => Math.round(d * Math.pow(10, places)) / Math.pow(10, places);

async function loadData(room, time) {
  let params = `room=${room}`;
  if (time) params = `${params}&time=${time}`;
  const response = await fetch(`query-ebur.php?${params}`);

  const data = await response.json();

  return {
    l: data["l"].map((x) => [x.time, x.S]),
    r: data["r"].map((x) => [x.time, x.S]),
  };
}

async function chart(room, element, refreshInterval, onTick) {
  const data = await loadData(room);

  const primary = "midnightblue";
  const backup = "goldenrod";

  const cfg = {
    animation: false,
    tooltip: { trigger: "axis" },
    backgroundColor: "transparent",
    color: ["midnightblue", "goldenrod"],

    grid: { left: 0, right: 0, top: 0, bottom: 0 },
    xAxis: {
      type: "time",
      min: Date.now() - 5 * 60 * 1000,
      max: Date.now(),
      show: false,
    },
    yAxis: [{ type: "value", name: "волуме", min: -52, max: 0, show: false }],
    series: [
      {
        name: "L",
        type: "line",
        smooth: true,
        symbol: "none",
        data: data["l"],
        tooltip: { valueFormatter: (v) => `${round(v)}` },
        markArea: {
          silent: true,
          data: [
            [
              { yAxis: -52, itemStyle: { color: "red", opacity: 0.2 } },
              { yAxis: -30 },
            ],
            [
              { yAxis: -30, itemStyle: { color: "green", opacity: 0.2 } },
              { yAxis: -14 },
            ],
            [
              { yAxis: -14, itemStyle: { color: "yellow", opacity: 0.2 } },
              { yAxis: -0 },
            ],
          ],
        },
      },
      {
        name: "R",
        type: "line",
        smooth: true,
        symbol: "none",
        lineStyle: { width: 1 },
        data: data["r"],
        tooltip: { valueFormatter: (v) => `${round(v)}` },
      },
    ],
  };

  let chart = echarts.init(element);
  chart.setOption(cfg);

  setInterval(function () {
    tick(chart, room);
    if (onTick) onTick(chart, room);
  }, refreshInterval);

  return chart;
}

async function tick(roomChart, room) {
  const option = roomChart.getOption();

  let dataLeft = option.series[0].data.slice();
  let dataRight = option.series[1].data.slice();

  let lastTs;
  try {
    lastTs = Math.min(
      dataLeft.data[dataLeft.data.length - 1][0],
      dataRight.data[dataRight.data.length - 1][0],
    );
  } catch {
    lastTs = undefined;
  }

  let data = await loadData(room, lastTs ? lastTs + 1 : undefined);

  dataLeft.splice(0, data["l"].length);
  dataRight.splice(0, data["r"].length);

  dataLeft.push(...data["l"]);
  dataRight.push(...data["r"]);

  roomChart.setOption({
    xAxis: {
      type: "time",
      min: Date.now() - 5 * 60 * 1000, // 5 minutes
      max: Date.now(),
      show: false,
    },
    series: [
      { name: "L", data: dataLeft },
      { name: "R", data: dataRight },
    ],
  });
}

