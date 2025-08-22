import { useState } from "react";

// Small helper: generate a request-id (crypto.randomUUID available in modern browsers)
function reqId() {
  try {
    return crypto.randomUUID();
  } catch {
    return Math.random().toString(36).slice(2);
  }
}

export default function SystemHealth() {
  const [apiMsg, setApiMsg] = useState("Idle");
  const [verMsg, setVerMsg] = useState("Idle");
  const [ipcMsg, setIpcMsg] = useState("Idle");
  const [cfgMsg, setCfgMsg] = useState("Idle");

  async function pingApi() {
    try {
      const res = await fetch("http://127.0.0.1:8000/health", {
        headers: { "x-request-id": reqId() },
      });
      const data = await res.json();
      setApiMsg(`API: ${data.status} (${data.service})`);
    } catch (e) {
      setApiMsg("API unreachable");
    }
  }

  async function getVersion() {
    try {
      const res = await fetch("http://127.0.0.1:8000/version", {
        headers: { "x-request-id": reqId() },
      });
      const data = await res.json();
      setVerMsg(`Version: ${data.version}`);
    } catch {
      setVerMsg("Version unavailable");
    }
  }

  async function ipcEcho() {
    try {
      if (window.forge?.echo) {
        const echoed = await window.forge.echo("hello-from-ui");
        setIpcMsg(`IPC echo: ${echoed}`);
      } else {
        setIpcMsg("No Electron bridge detected");
      }
    } catch {
      setIpcMsg("IPC failed");
    }
  }

  function uiEnv() {
    // Minimal config display; extend later as needed
    const apiUrl = (import.meta as any).env?.VITE_API_URL ?? "http://127.0.0.1:8000";
    const inElectron = !!window.forge?.hasElectron;
    setCfgMsg(`VITE_API_URL=${apiUrl} | electron=${inElectron}`);
  }

  return (
    <div style={{ padding: 16, border: "1px solid #ddd", borderRadius: 8, marginTop: 16 }}>
      <h2>System Health</h2>
      <div style={{ display: "grid", gap: 8, gridTemplateColumns: "repeat(2, minmax(0, 1fr))" }}>
        <button onClick={pingApi}>Ping API (/health)</button>
        <div>{apiMsg}</div>
        <button onClick={getVersion}>API Version (/version)</button>
        <div>{verMsg}</div>
        <button onClick={ipcEcho}>Electron IPC echo</button>
        <div>{ipcMsg}</div>
        <button onClick={uiEnv}>UI Env / Config</button>
        <div>{cfgMsg}</div>
      </div>
    </div>
  );
}
