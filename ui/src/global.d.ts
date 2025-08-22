export {};

declare global {
  interface Window {
    forge?: {
      hasElectron: boolean;
      echo: (msg: string) => Promise<string>;
    };
  }

  interface ImportMetaEnv {
    readonly VITE_API_URL?: string;
  }

  interface ImportMeta {
    readonly env: ImportMetaEnv;
  }
}
