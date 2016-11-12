'use strict';

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

app.ports.chartAttempts.subscribe(function(attempts) {
  console.log("Port (js): chartAttempts: " + attempts);

  setTimeout(function() {
    var ctx = document.getElementById("attemptChart");

    var wpmData = attempts.map(function(a) {
      return { x: newDate(a.completedAt), y: Math.round (a.wpm * 10) / 10 };
    });

    var accuracyData = attempts.map(function(a) {
      return { x: newDate(a.completedAt), y: Math.round (a.accuracy * 100) / 100 };
    });

    var myChart = new Chart(ctx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'WPM',
                radius: 5,
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                xAxisID: "time",
                yAxisID: "wpm",
                data: wpmData
            } , {
                label: 'Accuracy',
                radius: 5,
                backgroundColor: 'rgba(255, 206, 86, 0.2)',
                xAxisID: "time",
                yAxisID: "accuracy",
                data: accuracyData
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


  }, 100);
});
