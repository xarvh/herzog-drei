function addGamepadPort(elmApp) {

  var getGamepads =
    typeof navigator.getGamepads === 'function' ? function () { return navigator.getGamepads(); } :
    typeof navigator.webkitGetGamepads === 'function' ? function () { return navigator.webkitGetGamepads(); } :
    function () { return []; }

  var frames = [];
  requestAnimationFrame(onAnimationFrame);

  function onAnimationFrame(timestamp) {
    requestAnimationFrame(onAnimationFrame);
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
        timestamp: g.timestamp,
      });
    }

    frames.unshift({ gamepads: serialisedGamepads, timestamp: timestamp });
    if (frames.length > 60) frames.pop();

    elmApp.ports.gamepad.send(frames);
  }
}
