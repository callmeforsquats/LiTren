from pydantic_settings import BaseSettings, SettingsConfigDict


class Config(BaseSettings):
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "password"
    DB_HOST: str = "127.0.0.1"
    DB_PORT: int = 5432
    DB_NAME: str = "db"
    DB_SEED: bool = False
    SECRET_KEY: str = "secret_key"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_MINUTES: int = 30
    REFRESH_TOKEN_DAYS: int = 30
    ADMIN_EMAIL: str = "her"
    ADMIN_PASSWORD: str = "herovich"
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    ENABLE_ML: bool = False

    @property
    def DB_URL(self) -> str:
        return f"postgresql://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"

    model_config = SettingsConfigDict(env_file=".env")


settings = Config()
