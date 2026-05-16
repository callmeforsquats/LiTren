from fastapi import status


class BaseError(Exception):
    status_code = status.HTTP_400_BAD_REQUEST
    message = "Произошла ошибка"

    def __init__(self, message: str | None = None):
        if message:
            self.message = message
        super().__init__(self.message)

    pass


class NotFoundError(BaseError):
    status_code = status.HTTP_404_NOT_FOUND
    message = "Не найдено"


class AlreadExistsError(BaseError):
    message = "Уже существует"
    status_code = status.HTTP_409_CONFLICT


class PermissionDeniedError(BaseError):
    message = "Доступ запрещён"
    status_code = status.HTTP_403_FORBIDDEN


class UserNotFoundError(BaseError):
    message = "Пользователь не найден"
    status_code = status.HTTP_401_UNAUTHORIZED


class UnauthorizedError(BaseError):
    message = "Требуется авторизация"
    status_code = status.HTTP_401_UNAUTHORIZED
