var mountNode = document.getElementById('main');

var app = Elm.Main.embed(mountNode);

document.onkeydown = function(e) {
  if (e.keyCode === 8) {
    app.ports.keyDown.send(e.keyCode)

    e.preventDefault();
    e.stopPropagation()
  }
}

document.onkeypress = function(e) {
  if (e.keyCode !== 8) {
    app.ports.keyPress.send(e.keyCode)

    e.preventDefault();
    e.stopPropagation()
  }
}

function newDate(epoc) {
  return moment(epoc).toDate();
}

var timeFormat = 'MM/DD/YYYY HH:mm';

var ctx = document.getElementById("myChart");

var myChart = new Chart(ctx, {
    type: 'line',
    data: {
        datasets: [{
            label: 'WPM',
            radius: 5,
            backgroundColor: 'rgba(54, 162, 235, 0.2)',
            xAxisID: "time",
            yAxisID: "wpm",
            data: [{
                      x: newDate(1478606177234),
                      y: 30
                  }, {
                      x: newDate(1478706177234),
                      y: 32
                  }, {
                      x: newDate(1478708177234),
                      y: 33
                  }]
        } , {
            label: 'Accuracy',
            radius: 5,
            backgroundColor: 'rgba(255, 206, 86, 0.2)',
            xAxisID: "time",
            yAxisID: "accuracy",
            data: [{
                    x: newDate(1478606177234),
                    y: 99.7
                }, {
                    x: newDate(1478706177234),
                    y: 90.456
                }, {
                    x: newDate(1478708177234),
                    y: 94.34
                }]
        }]
    },
    options: {
        showLines: false,
        responsive: false,
        maintainAspectRatio: false,
        scales: {
            xAxes: [{
                type: 'time',
                position: 'bottom',
                id: 'time'
            }],
            yAxes: [{
                position: "left",
                id: "wpm",
                display: true,
                ticks: {
                  beginAtZero: true,
                  suggestedMax: 100
                }
            }, {
                position: "right",
                id: "accuracy",
                display: false,
                ticks: {
                  beginAtZero: true
                }
            }]
        }
    }
});
