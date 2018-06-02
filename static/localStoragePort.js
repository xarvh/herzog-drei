function addLocalStoragePort(elmApp) {
  elmApp.ports.localStorageSet.subscribe(function (args) {
    localStorage.setItem(args.key, args.value);
  });
}
