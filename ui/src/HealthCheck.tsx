import { useState } from "react";

export default function HealthCheck() {
  const [msg, setMsg] = useState("Click to ping API");

  async function ping() {
    try {
      const res = await fetch("http://127.0.0.1:8000/health");
      const data = await res.json();
      setMsg(`API: ${data.status} (${data.service})`);
    } catch {
      setMsg("API unreachable");
    }
  }

  return (
    <div>
      <button onClick={ping}>Ping API</button>
      <div style={{ marginTop: 8 }}>{msg}</div>
    </div>
  );
}
