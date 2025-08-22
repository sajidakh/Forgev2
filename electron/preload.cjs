// Preload runs in an isolated world; expose a tiny, safe API.
const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("forge", {
  hasElectron: true,
  echo: (msg) => ipcRenderer.invoke("forge:echo", msg),
});
