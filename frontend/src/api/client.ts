// src/api/client.ts
import { uiState } from "../states/ui.svelte";
export const BASE_URL = import.meta.env.API_BASE_URL || "http://localhost:1234/api";
let isRefreshing = false;

// Счётчик активных запросов для глобального лоадера
let activeRequests = 0;

function updateGlobalLoader() {
  if (activeRequests > 0) {
    uiState.startGlobalLoading();
  } else {
    uiState.stopGlobalLoading();
  }
}

export async function apiFetch<T>(
  endpoint: string,
  options: RequestInit = {},
  isRetry = false,
): Promise<T> {
  const url = `${BASE_URL}${endpoint}`;
  options.credentials = "include";

  if (options.body && !(options.body instanceof FormData)) {
    options.headers = {
      "Content-Type": "application/json",
      ...options.headers,
    };
  }

  activeRequests++;
  updateGlobalLoader();

  try {
    const response = await fetch(url, options);

    if (!response.ok) {
      if (response.status === 401 && !isRetry) {
        const success = await refresh();
        if (success) {
          return apiFetch<T>(endpoint, options, true);
        } else {
          const { userState } = await import("../states/user.svelte");
          if (userState.current !== null) {
            uiState.error("Сессия истекла. Войдите заново.");
          }
          throw new Error("Сессия истекла. Войдите заново.");
        }
      }

      const errorData = await response.json().catch(() => ({}));
      const errorMessage = errorData.detail || `Ошибка: ${response.status}`;
      uiState.error(errorMessage);
      throw new Error(errorMessage);
    }

    return response.json() as Promise<T>;
  } finally {
    activeRequests--;
    updateGlobalLoader();
  }
}

async function refresh(): Promise<boolean> {
  if (isRefreshing) return false;
  isRefreshing = true;
  try {
    const res = await fetch(`${BASE_URL}/users/refresh`, {
      method: "GET",
      credentials: "include",
    });
    return res.ok;
  } catch {
    return false;
  } finally {
    isRefreshing = false;
  }
}

export function debounce<Args extends any[]>(
  fn: (...args: Args) => any,
  delay: number,
) {
  let timeoutId: ReturnType<typeof setTimeout> | undefined;

  const debounced = (...args: Args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      fn(...args);
    }, delay);
  };

  // Метод для принудительной отмены запланированного запроса (например, при размонтировании компонента)
  debounced.cancel = () => {
    clearTimeout(timeoutId);
  };

  return debounced;
}
