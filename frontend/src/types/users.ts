export class UserBase {
  email: string = "";
  password: string = "";
  constructor(init?: Partial<UserBase>) {
    Object.assign(this, init);
  }
}
export interface UserRead {
  id: number;
  email: string;
  is_admin: boolean;
}

export interface UserInfo extends UserRead {
  picture_url: string | null;
}

// ------- Towns ---------

export class TownCreate {
  name: string = "";
  fias_id: string = "";
  constructor(init?: Partial<TownCreate>) {
    Object.assign(this, init);
  }
}

// --------- Streets ---------

export class StreetCreate {
  name: string = "";
  fias_id: string = "";
  constructor(init?: Partial<StreetCreate>) {
    Object.assign(this, init);
  }
}

// ------- Addresses --------

export class AddressCreate {
  town: TownCreate = new TownCreate();
  street: StreetCreate = new StreetCreate();
  house: string = "";
  flat: string | null = null;
  fias_id: string = "";
  is_default: boolean | null = null;
  constructor(init?: Partial<AddressCreate>) {
    Object.assign(this, init);
  }
}

export interface AddressRead {
  full_address: string;
  fias_id: string;
}

// ------ Carts ----------

export class ItemCreate {
  quantity: number = 1;
  book_id: number = 0;
  constructor(init?: Partial<ItemCreate>) {
    Object.assign(this, init);
  }
}

export interface ItemRead {
  book_id: number;
  quantity: number;
  title: string;
  price: number;
  picture_url: string | null;
}

//--------- Orders ----------

export enum Status {
  "CANCELED",
  "PAID",
  "PENDING",
  "SHIPPED",
  "COMPLETED",
}

export class OrderCreate {
  items: number[] = [];
  address_id: string = "";
  constructor(init?: Partial<OrderCreate>) {
    Object.assign(this, init);
  }
}

export interface OrderRead {
  id: number;
  status: Status;
  total_price: number;
  full_address: string;
  created_at: string;
}

export interface OrderInfo extends OrderRead {
  items: ItemRead[];
}

// ------ Reviews --------

export class ReviewCreate {
  rating: number = 5;
  text: string | null = null;
  constructor(init?: Partial<ReviewCreate>) {
    Object.assign(this, init);
  }
}

export interface ReviewRead {
  id: number;
  rating: number;
  book_id: number;
  book_title: string;
  text: string | null;
  created_at: string;
}

export class ReviewFilter {
  user_id: number | null = null;
  limit: number = 5;
  offset: number = 0;
  good_first: boolean = true;
  bad_first: boolean = false;

  constructor(init?: Partial<ReviewFilter>) {
    Object.assign(this, init);
  }
}

export class OrderFilter {
  book_id: number | null = null;
  user_id: number | null = null;
  town_id: string | null = null;
  min_price: number | null = null;
  max_price: number | null = null;
  status: Status | null = null;
  limit: number | null = null;
  offset: number = 0;
  constructor(init?: Partial<OrderFilter>) {
    Object.assign(this, init);
  }
}
