'use strict';

const { Elm } = require('../../src/Main.elm');

var app = Elm.Main.init();

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

var DETECT_MARGIN_LINES = 3;
var TARGET_MARGIN_LINES = 5;

app.ports.scrollIfNearEdge.subscribe(function(nothing) {
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
