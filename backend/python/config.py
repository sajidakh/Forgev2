from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="FORGE_",
        env_file=".env",
        env_file_encoding="utf-8",
    )

    api_name: str = "Forge API"
    api_version: str = "0.1.0-step2"
    cors_origins: list[str] = ["http://127.0.0.1:5173", "http://localhost:5173"]
    log_dir: str = "logs"
