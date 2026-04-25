import { useSelector } from 'react-redux';
import { RootState } from '../state/store';
import { canWrite, canReadAllBarangays, type UserRole } from '../interfaces/user';

export function usePermissions() {
  const user = useSelector((state: RootState) => state.user.user);
  const role = user?.role as UserRole | undefined;

  return {
    role,
    isAdmin: role === 'admin',
    isStaff: role === 'staff',
    isDrrmo: role === 'drrmo',
    canWrite: canWrite(role),
    canReadAllBarangays: canReadAllBarangays(role),
    barangayName: user?.barangay_name ?? null,
  };
}
