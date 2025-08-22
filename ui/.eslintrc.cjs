/** @type {import("eslint").Linter.Config} */
module.exports = {
  root: true,
  env: { browser: true, node: true, es2021: true },
  parser: "@typescript-eslint/parser",
  parserOptions: { project: false, ecmaFeatures: { jsx: true } },
  plugins: ["@typescript-eslint", "react", "react-hooks"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
  ],
  settings: { react: { version: "detect" } },
  ignorePatterns: ["dist", "node_modules"],
};
