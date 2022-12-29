'use strict';

require('./moment.min.js')
require('./Chart.bundle.min.js')

if (module.hot) {
  module.hot.dispose(() => {
    window.location.reload();
  });
}

import { Elm } from '../../src/Main.elm'

function initializeApp() {
  const app = Elm.Main.init({
    node: document.getElementById('main'),
    flags: {}
  });

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

  var DETECT_MARGIN_LINES = 3;
  var TARGET_MARGIN_LINES = 5;

  app.ports.scrollIfNearEdge.subscribe(function(nothing) {
    console.log("Port (js): scrollIfNearEdge");
    setTimeout(function() {
      var currentStep = document.getElementById("current");

      if (currentStep !== null) {
        var height      = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
        var currentRect = currentStep.getBoundingClientRect();

        if (currentRect.bottom + (currentRect.height * DETECT_MARGIN_LINES) > height) {
          window.scrollBy(0, height - (currentRect.height * TARGET_MARGIN_LINES));
        } else if (currentRect.top - (currentRect.height * DETECT_MARGIN_LINES) <= 0) {
          window.scrollBy(0, -1 * (height - (currentRect.height * TARGET_MARGIN_LINES)));
        }
      }
    }, 50);
  });

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
}

initializeApp();
