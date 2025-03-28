async function loadData(room, time) {
    let params = ``;
    if(time) params = `${params}&time=${time}`;
    const response = await fetch(`query-ebur.php?${params}`);
    return response.json();
}


async function chart(room, element, refreshInterval, onTick) {
    const data = await loadData(room);

    const primary = 'midnightblue';
    const backup = 'goldenrod';

    const cfg = {
        data: {
            datasets: [
            {
                type: 'line',
                label: 'L',
                pointRadius: 0,
                backgroundColor: primary,
                borderColor: primary,
                borderWidth: 2,
                data: data['l'],
                parsing: { xAxisKey: 'time', yAxisKey: 'S' }
            },
            {
                type: 'line',
                label: 'R',
                pointRadius: 0,
                backgroundColor: backup,
                borderColor: backup,
                borderWidth: 1,
                data: data['r'],
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
                        backgroundColor: 'rgba(255, 0, 0, 0.25)',
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
    let dataLeft = roomChart.data.datasets[0];
    let dataRight = roomChart.data.datasets[1];

    let lastTs;
    try {
        lastTs = Math.min(dataLeft.data[dataLeft.data.length - 1].time, dataRight.data[dataRight.data.length - 1].time);
    } catch {
        lastTs = undefined;
    }

    let data = await loadData(room, lastTs ? lastTs + 1 : undefined);

    dataLeft.data.splice(0, data['l'].length);
    dataRight.data.splice(0, data['r'].length);

    dataLeft.data.push(...data['l']);
    dataRight.data.push(...data['r']);

    roomChart.update();
}
