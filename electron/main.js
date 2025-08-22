import { app, BrowserWindow, ipcMain, session } from "electron";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const createWindow = async () => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true,
      allowRunningInsecureContent: false,
      preload: join(__dirname, "preload.cjs"),
    },
  });
  await win.loadURL("http://127.0.0.1:5173/");
};

app.whenReady().then(() => {
  // Deny all permission prompts by default
  session.defaultSession.setPermissionRequestHandler((_wc, _perm, cb) => cb(false));
  createWindow();
});

ipcMain.handle("forge:echo", async (_event, msg) => String(msg));

app.on("window-all-closed", () => { if (process.platform !== "darwin") app.quit(); });
