function addGamepadPort(elmApp) {


  var getGamepads =
    typeof navigator.getGamepads === 'function' ? function () { return navigator.getGamepads(); } :
    typeof navigator.webkitGetGamepads === 'function' ? function () { return navigator.webkitGetGamepads(); } :
    function () { return []; }


  var previousTimestamp;
  requestAnimationFrame(function (timestamp) {
    previousTimestamp = timestamp;
    raf();
  })


  function raf() {
    requestAnimationFrame(onAnimationFrame);
  }


  function onAnimationFrame(timestamp) {
    raf();

    var serialisedGamepads = [];
    var gamepads = getGamepads();
    for (var i = 0; i < gamepads.length; i++) {
      serialisedGamepads.push(copyGamepad(gamepads[i]));
    }

    elmApp.ports.gamepad.send([
      //timestamp - previousTimestamp,
      timestamp,
      serialisedGamepads,
    ]);

    previousTimestamp = timestamp;
  }


  function copyGamepad(g) {
    return !g ? null : {
      axes: g.axes,
      buttons: g.buttons.map(function (b) { return [ b.pressed, b.value ]; }),
      connected: g.connected,
      id: g.id,
      index: g.index,
      mapping: g.mapping,
      timestamp: g.timestamp,
    };
  }
}
