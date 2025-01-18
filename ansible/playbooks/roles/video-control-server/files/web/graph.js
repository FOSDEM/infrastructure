async function loadData(room) {
    const response = await fetch(`query-ebur.php?room=${room}`);
    return response.json();
}


async function chart(room, element, refreshInterval, onTick) {
    const data = await loadData(room);

    const cfg = {
        data: {
            datasets: [
            {
                type: 'line',
                label: 'M',
                pointRadius: 0,
                backgroundColor: 'darkgoldenrod',
                borderColor: 'darkgoldenrod',
                borderWidth: 1,
                data: data,
                parsing: { xAxisKey: 'time', yAxisKey: 'M' }
            },
            {
                type: 'line',
                label: 'S',
                pointRadius: 0,
                backgroundColor: 'green',
                borderColor: 'green',
                borderWidth: 2,
                data: data,
                parsing: { xAxisKey: 'time', yAxisKey: 'S' }
            },
            ],
        },
        options: {
            animation: false,
            layout: { padding: 0 },
            plugins: {
                filler: {},
                annotation: { annotations: {
                    red: {
                        type: 'box',
                        yMin: -52,
                        yMax: -30,
                        backgroundColor: 'rgba(255,0,0,0.25)',
                        borderWidth: 0,
                    },
                    green: {
                        type: 'box',
                        yMin: -30,
                        yMax: -14,
                        backgroundColor: 'rgba(86, 166, 75, 0.25)',
                        borderWidth: 0,
                    },
                    yellow: {
                        type: 'box',
                        yMin: -14,
                        yMax: -0,
                        backgroundColor: 'rgba(224, 180, 0, 0.25)',
                        borderWidth: 0,
                    },
                }},
                legend: { display: false }
            },
            parsing: false,
            scales: {
                time:  {
                    axis: 'x',
                    type: 'time',
                    display: false,
                },
                S:  {
                    axis: 'y',
                    type: 'linear',
                    display: false,
                    min: -52,
                    max: 0,
                },
                M:  {
                    axis: 'y',
                    type: 'linear',
                    display: false,
                    min: -60,
                    max: 0,
                },
            },
        }
    }

    Chart.register({id: 'annotation'});
    let chart = new Chart(element, cfg);

    setInterval(function() {
        tick(chart, room);
        if(onTick) onTick(chart, room);
    }, refreshInterval);

    return chart;
}


async function tick(roomChart, room) {
    let data = await loadData(room);

    roomChart.data.datasets[0].data = data;
    roomChart.data.datasets[1].data = data;

    roomChart.update();
}
