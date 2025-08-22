/* Simple error boundary to catch renderer crashes */
import React from "react";

type Props = { children: React.ReactNode };
type State = { hasError: boolean; info?: string };

export default class ErrorBoundary extends React.Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    this.setState({ info: message });
    // console.error("ErrorBoundary caught:", error);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: 16, color: "#f33" }}>Renderer error. See console for details.</div>
      );
    }
    return this.props.children;
  }
}
