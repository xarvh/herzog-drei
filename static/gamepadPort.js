function addGamepadPort(elmApp) {

  var getGamepads =
    typeof navigator.getGamepads === 'function' ? function () { return navigator.getGamepads(); } :
    typeof navigator.webkitGetGamepads === 'function' ? function () { return navigator.webkitGetGamepads(); } :
    function () { return []; }


  var previousFrame;
  requestAnimationFrame(function (timestamp) {
    previousFrame = getFrame(timestamp);
    requestAnimationFrame(onAnimationFrame);
  });


  function onAnimationFrame(timestamp) {
    requestAnimationFrame(onAnimationFrame);

    var currentFrame = getFrame(timestamp);
    elmApp.ports.gamepad.send([ currentFrame, previousFrame ]);

    previousFrame = currentFrame;
  }


  function getFrame(timestamp) {
    var rawGamepads = getGamepads();

    var serialisedGamepads = [];
    for (var i = 0; i < rawGamepads.length; i++) {
      var g = rawGamepads[i];

      // All browsers running under Windows 10 will sometimes throw in a zombie gamepad
      // object, unrelated to any physical gamepad and never updated.
      // Since this gamepad has always timestamp == 0, we use timestamp > 0 to discard it.
      if (g && g.connected && g.timestamp > 0) serialisedGamepads.push({
        axes: g.axes,
        buttons: g.buttons.map(function (b) { return [ b.pressed, b.value ]; }),
        id: g.id,
        index: g.index + 1,
        mapping: g.mapping,
      });
    }

    return { gamepads: serialisedGamepads, timestamp: timestamp };
  }
}
