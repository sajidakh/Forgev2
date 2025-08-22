export {};

declare global {
  interface Window {
    forge?: {
      hasElectron: boolean;
      echo: (msg: string) => Promise<string>;
    };
  }
}
