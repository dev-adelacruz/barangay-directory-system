export type UserRole = 'admin' | 'staff' | 'drrmo';

export interface User {
  id: number;
  email: string;
  role: UserRole;
  barangay_name: string | null;
  full_name: string | null;
}

export interface UserState {
  isSignedIn: boolean;
  token: string | null;
  user: User | null;
  isLoading: boolean;
  error: string | null;
}

export const ROLE_LABELS: Record<UserRole, string> = {
  admin: 'Barangay Captain / Admin',
  staff: 'Barangay Staff',
  drrmo: 'DRRMO Officer',
};

export function canWrite(role: UserRole | undefined): boolean {
  return role === 'admin' || role === 'staff';
}

export function canReadAllBarangays(role: UserRole | undefined): boolean {
  return role === 'admin' || role === 'drrmo';
}
