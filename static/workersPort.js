/*
 *
 *
 * IMPORTANT: Loaded scripts should register themselves by calling hook_addWrappedWorker()
 *
 * This horror and its necessity are explained at https://stackoverflow.com/a/33432215
 *
 *
 */
function hook_addWrappedWorker(workerWrappedInAFunction) {
  assert.isFunction(workerWrappedInAFunction, 'workerWrappedInAFunction');

  const scripts = document.getElementsByTagName('script');
  const lastScript = scripts[scripts.length - 1];
  const url = lastScript.src;

  assert(url, 'url');
  assert(!workerWrappedInAFunctionByUrl[url], 'script already registered');

  workerWrappedInAFunctionByUrl[url] = workerWrappedInAFunction;
  script.onLoadCallback(workerWrappedInAFunction);
}


const workerWrappedInAFunctionByUrl = {};


function loadWorkerScript(url, cb) {
  const workerWrappedInAFunction = workerWrappedInAFunctionByUrl[url];

  if (workerWrappedInAFunction)
    return cb(workerWrappedInAFunction);

  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = url;

  /* TODO deal with failures */
  script.onLoadCallback = cb;

  document.getElementsByTagName('head')[0].appendChild(script);
}


function createWorkerInstance(workerWrappedInAFunction) {
  return new Worker(URL.createObjectURL(new Blob(["("+workerWrappedInAFunction.toString()+")()"], {type: 'text/javascript'})));
}



/*
 * Stuff that should really live in its own module
 */
function assert(test, message) {
  if (!test) throw new Error(message || 'assertion failed');
}

assert.isFunction = function assert_isFunction(item, name) {
  assert(typeof item === 'function', name + ' should be a function');
}



/*
 * Ports
 */
const workerInstanceById = {};


function addWorkerInstance(url, originalId, onMessage) {
  // TODO try { workerInstanceById[id].close(); } catch () {}

  // this means that the worker is loading
  workerInstanceById[originalId] = url;

  // On load, create all workers with the specified URL that have not been created
  loadWorkerScript(url, (workerWrappedInAFunction) => {
    Object.keys(workerInstanceById).filter((id) => workerInstanceById[id] === url).forEach((id) => {
      const worker = createWorkerInstance(workerWrappedInAFunction);
      workerInstanceById[id] = worker;
      worker.onmessage = onMessage(id);
      worker.postMessage('init', id);
    });
  })
}


function addWorkersPorts(elmApp) {

  // js -> Elm port: onWorkerMessage
  const onMessage = (id) => (message) => elmApp.ports.onWorkerMessage.send([ id, message ]);

  // Elm -> js port: addWorkerInstance
  elmApp.ports.addWorker.subscribe(({ url, id }) => addWorkerInstance(url, id, onMessage))

  // Elm -> js port: sendMessageToWorker
  elmApp.ports.sendMessageToWorker.subscribe(({ id, message }) => workerInstanceById[id].postMessage(message));
}
