import { app, BrowserWindow } from 'electron';

const createWindow = async () => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
    }
  });

  // Dev: point to Vite dev server (Step 1); later we’ll serve a built UI.
  await win.loadURL('http://127.0.0.1:5173/');
};

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
