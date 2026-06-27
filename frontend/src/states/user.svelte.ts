import { usersApi } from "../api/users";
import type { UserInfo, UserBase } from "../types/users";

class UserState {
  // Реактивные переменные состояния
  current = $state<UserInfo | null>(null);
  isLoading = $state(true);

  async checkAuth() {
    this.isLoading = true;
    try {
      this.current = await usersApi.getMe();
    } catch {
      this.current = null; // Если 401 ошибка, значит пользователь гость
    } finally {
      this.isLoading = false;
    }
  }

  isAdmin = $derived(!!this.current?.is_admin);

  async login(credentials: UserBase) {
    await usersApi.login(credentials);
    await this.checkAuth(); // Перезапрашиваем профиль после успешного входа
  }

  async logout() {
    await usersApi.logout();
    this.current = null;
  }

  clearUser() {
    this.current = null;
  }
}

export const userState = new UserState();
