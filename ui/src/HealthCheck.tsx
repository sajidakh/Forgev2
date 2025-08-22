import { useState } from 'react';

export default function HealthCheck() {
  const [msg, setMsg] = useState<string>('Click to ping API');

  const ping = async () => {
    try {
      const res = await fetch('http://127.0.0.1:8000/health');
      const data = await res.json();
      setMsg(\API: \ (\)\);
    } catch (e) {
      setMsg('API unreachable');
    }
  };

  return (
    <div style={{ padding: 16 }}>
      <button onClick={ping}>Ping API</button>
      <div style={{ marginTop: 8 }}>{msg}</div>
    </div>
  );
}
