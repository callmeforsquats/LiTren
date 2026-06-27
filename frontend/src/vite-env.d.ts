/// <reference types="svelte" />
/// <reference types="vite/client" />

import "svelte/elements";

declare module "*.svelte" {
  import type { Component } from "svelte";
  const component: Component<any, any, any>;
  export default component;
}

declare module "*.svg" {
  const content: string;
  export default content;
}
declare module "*.png" {
  const content: string;
  export default content;
}
