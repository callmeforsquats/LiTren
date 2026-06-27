// src/states/ui.svelte.ts

type ToastType = "success" | "error" | "info" | "warning";

interface Toast {
  id: string;
  message: string;
  type: ToastType;
  duration: number;
}

class UIState {
  toasts = $state<Toast[]>([]);
  isGlobalLoading = $state(false);
  activeModal = $state<string | null>(null);
  modalData = $state<any>(null);

  // Показ уведомления
  showToast(
    message: string,
    type: ToastType = "info",
    duration: number = 3000,
  ) {
    const id = Math.random().toString(36).substring(2, 9);
    const toast: Toast = { id, message, type, duration };

    this.toasts = [...this.toasts, toast];

    if (duration > 0) {
      setTimeout(() => {
        this.hideToast(id);
      }, duration);
    }

    return id;
  }

  hideToast(id: string) {
    this.toasts = this.toasts.filter((t) => t.id !== id);
  }

  // Удобные обёртки
  success(message: string, duration?: number) {
    return this.showToast(message, "success", duration);
  }

  error(message: string, duration?: number) {
    return this.showToast(message, "error", duration);
  }

  info(message: string, duration?: number) {
    return this.showToast(message, "info", duration);
  }

  warning(message: string, duration?: number) {
    return this.showToast(message, "warning", duration);
  }

  // Модальные окна
  openModal(name: string, data?: any) {
    this.activeModal = name;
    this.modalData = data;
  }

  closeModal() {
    this.activeModal = null;
    this.modalData = null;
  }

  // Глобальная загрузка
  startGlobalLoading() {
    this.isGlobalLoading = true;
  }

  stopGlobalLoading() {
    this.isGlobalLoading = false;
  }
}

export const uiState = new UIState();
