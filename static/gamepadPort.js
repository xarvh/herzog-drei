function addGamepadPort(elmApp) {


  var getGamepads =
    typeof navigator.getGamepads === 'function' ? function () { return navigator.getGamepads(); } :
    typeof navigator.webkitGetGamepads === 'function' ? function () { return navigator.webkitGetGamepads(); } :
    function () { return []; }


  var blobs = [];
  requestAnimationFrame(onAnimationFrame);


  function onAnimationFrame(timestamp) {
    requestAnimationFrame(onAnimationFrame);

    var serialisedGamepads = [];
    var gamepads = getGamepads();
    for (var i = 0; i < gamepads.length; i++) {
      serialisedGamepads.push(copyGamepad(gamepads[i]));
    }

    blobs.unshift({ gamepads: serialisedGamepads, timestamp: timestamp });
    if (blobs.length > 60) blobs.pop();
    elmApp.ports.gamepad.send(blobs);
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
