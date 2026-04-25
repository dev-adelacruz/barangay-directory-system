# frozen_string_literal: true
# ============================================================
# Rails Template: Rails 7 + React + Redux + JWT Auth
# Usage:
#   rails new myapp -d postgresql -m path/to/template.rb
#   rails new myapp -d postgresql -m https://raw.githubusercontent.com/YOUR_USERNAME/rails_with_redux_and_jwt_auth/main/template.rb
# ============================================================

def source_paths
  [__dir__]
end

# ── Gems ─────────────────────────────────────────────────────
say "== Adding gems ==", :green

gem "blueprinter"
gem "devise"
gem "devise-jwt"
gem "rack-cors"
gem "vite_rails"
gem "rename"
gem "rswag-api"
gem "rswag-ui"

gem_group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry", "~> 0.15.0"
  gem "rspec-rails", "~> 6.1.0"
  gem "rswag-specs"
  gem "rubocop-ordered_methods", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false
  gem "shoulda-matchers", "~> 6.0"
end

gem_group :development do
  gem "web-console"
end

# ── Bundle install ────────────────────────────────────────────
say "== Installing gems ==", :green
run "bundle install"

# ── Vite Rails setup ─────────────────────────────────────────
say "== Setting up Vite Rails ==", :green
run "bundle exec vite install"

# ── JS dependencies ───────────────────────────────────────────
say "== Adding JS dependencies ==", :green
run "yarn add react react-dom react-router-dom react-redux @reduxjs/toolkit lucide-react tailwindcss @tailwindcss/vite"
run "yarn add --dev @vitejs/plugin-react @types/react @types/react-dom @types/styled-components typescript vite vite-plugin-ruby vite-tsconfig-paths"

# ── vite.config.ts ───────────────────────────────────────────
say "== Writing vite.config.ts ==", :green
create_file "vite.config.ts", force: true do
  <<~TS
    import { defineConfig } from 'vite'
    import RubyPlugin from 'vite-plugin-ruby'
    import tailwindcss from "@tailwindcss/vite";

    export default defineConfig({
      plugins: [
        RubyPlugin(),
        tailwindcss(),
      ]
    })
  TS
end

# ── tsconfig.json ────────────────────────────────────────────
say "== Writing tsconfig.json ==", :green
create_file "tsconfig.json", force: true do
  <<~JSON
    {
      "compilerOptions": {
        "target": "ESNext",
        "useDefineForClassFields": true,
        "lib": ["DOM", "DOM.Iterable", "ESNext"],
        "allowJs": false,
        "esModuleInterop": false,
        "allowSyntheticDefaultImports": true,
        "strict": true,
        "forceConsistentCasingInFileNames": true,
        "module": "ESNext",
        "moduleResolution": "Node",
        "resolveJsonModule": true,
        "isolatedModules": true,
        "noEmit": true,
        "jsx": "react-jsx",
        "baseUrl": "./",
        "paths": {
          "@/*": ["app/frontend/*"],
          "@api/*": ["app/frontend/api/services/*"]
        },
        "types": ["vite/client"],
        "skipLibCheck": true
      },
      "include": ["app/frontend/**/*"]
    }
  JSON
end

# ── tailwind.config.js ───────────────────────────────────────
say "== Writing tailwind.config.js ==", :green
create_file "tailwind.config.js", force: true do
  <<~JS
    // tailwind.config.js

    module.exports = {
      content: [
        "./app/frontend/**/*.{html,js,jsx,ts,tsx}", // Update according to your project file structure
      ],
      theme: {
        extend: {},
      },
      plugins: [],
    }
  JS
end

# ── Procfile.dev ─────────────────────────────────────────────
create_file "Procfile.dev", force: true do
  <<~PROC

    vite: bin/vite dev
    web: bin/rails s -p 3000
  PROC
end

# ── Application layout ───────────────────────────────────────
say "== Updating application layout ==", :green
remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.erb" do
  <<~ERB
    <!DOCTYPE html>
    <html>
      <head>
        <title>RailsTemplate</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <%= csrf_meta_tags %>
        <%= csp_meta_tag %>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300..800;1,300..800&display=swap" rel="stylesheet">
        <%= vite_client_tag %>
        <%= vite_stylesheet_tag 'tailwind.css' %>
      </head>

      <body class="h-full">
        <%= yield %>
        <div id="root"></div>
        <%= vite_javascript_tag 'application.tsx' %>
      </body>
    </html>
  ERB
end

# ── Frontend directory structure ─────────────────────────────
say "== Creating frontend structure ==", :green

# Tailwind CSS
create_file "app/frontend/assets/styles/tailwind.css" do
  <<~CSS
    @import 'tailwindcss';

    @keyframes gradient-shift {
      0%, 100% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
    }

    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-18px); }
    }

    @keyframes float-delayed {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-12px); }
    }

    @keyframes bar-fill {
      from { width: 0%; }
      to { width: var(--bar-width); }
    }

    @layer utilities {
      .animate-gradient-shift {
        background-size: 200% 200%;
        animation: gradient-shift 10s ease infinite;
      }
      .animate-float {
        animation: float 7s ease-in-out infinite;
      }
      .animate-float-delayed {
        animation: float-delayed 7s ease-in-out 2.5s infinite;
      }
      .animate-bar-fill {
        animation: bar-fill 1s ease-out forwards;
      }
    }

    @layer base {
      html, body, #root {
        @apply h-full;
        font-family: 'Open Sans', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }
    }
  CSS
end

# Entrypoint
create_file "app/frontend/entrypoints/application.tsx" do
  <<~TSX
    import { createRoot } from 'react-dom/client';
    import { App } from '../App';
    import { Provider } from 'react-redux';
    import { store } from '../state/store';

    const container = document.getElementById('root');

    if(container) {
      const root = createRoot(container);
      root.render(
        <Provider store={store}>
          <App />
        </Provider>
      )
    }
  TSX
end

# App.tsx
create_file "app/frontend/App.tsx" do
  <<~TSX
    import { FC, useEffect } from 'react';
    import { useDispatch } from 'react-redux';
    import { checkAuthStatus } from './state/user/userSlice';
    import AppRoutes from './routes';
    import './assets/styles/tailwind.css';

    export const App: FC = () => {
      const dispatch = useDispatch();

      useEffect(() => {
        // Check authentication status when the app loads
        dispatch(checkAuthStatus() as any);
      }, [dispatch]);

      return (
        <div className="h-screen w-screen">
          <AppRoutes />
        </div>
      );
    };
  TSX
end

# Routes
create_file "app/frontend/routes/index.tsx" do
  <<~TSX
    import React from 'react';
    import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
    import HomePage from '../pages/home';
    import LoginPage from '../pages/login';
    import ProtectedRoute from '../components/ProtectedRoute';

    const AppRoutes: React.FC = () => {
      return (
        <Router>
          <Routes>
            <Route path='/' element={
              <ProtectedRoute>
                <HomePage/>
              </ProtectedRoute>
            } />
            <Route path='/login' element={<LoginPage/>} />
          </Routes>
        </Router>
      )
    }

    export default AppRoutes;
  TSX
end

# Redux store
create_file "app/frontend/state/store.tsx" do
  <<~TSX
    import { configureStore } from '@reduxjs/toolkit';
    import userReducer from './user/userSlice';

    export const store = configureStore({
      reducer: {
        user: userReducer,
      }
    })

    export type RootState = ReturnType<typeof store.getState>;
    export type AppDispatch = typeof store.dispatch;
  TSX
end

# UserState interface
create_file "app/frontend/interfaces/state/userState.tsx" do
  <<~TSX
    interface UserState {
      isSignedIn: boolean;
      token: string | null;
      user: {
        id: number | null;
        email: string | null;
      } | null;
      isLoading: boolean;
      error: string | null;
    }
  TSX
end

# User slice
create_file "app/frontend/state/user/userSlice.tsx" do
  <<~TSX
    import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
    import { authService } from '../../services/authService';
    import { tokenStorage } from '../../services/tokenStorage';

    // Async thunks for authentication
    export const loginUser = createAsyncThunk(
      'user/login',
      async (credentials: { email: string; password: string }, { rejectWithValue }) => {
        try {
          const response = await authService.login(credentials);
          // Store token in localStorage without encryption for persistence
          await tokenStorage.storeToken(response.token, {
            encrypt: false,
            storageType: 'local'
          });
          return response;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Login failed');
        }
      }
    );

    export const logoutUser = createAsyncThunk(
      'user/logout',
      async (_, { rejectWithValue }) => {
        try {
          await authService.logout();
          // Clear token from storage on logout
          tokenStorage.clearToken();
          return null;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Logout failed');
        }
      }
    );

    export const checkAuthStatus = createAsyncThunk(
      'user/checkAuth',
      async (_, { rejectWithValue }) => {
        try {
          const token = await tokenStorage.getToken();
          
          if (token) {
            const isValid = await authService.validateToken(token);
            
            if (isValid) {
              // For now, return only the token; user data can be fetched separately if needed
              return { token, user: null };
            }
          }
          return null;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Auth check failed');
        }
      }
    );

    const initialState: UserState = {
      isSignedIn: false,
      token: null,
      user: null,
      isLoading: false,
      error: null
    };

    const userSlice = createSlice({
      name: 'User',
      initialState,
      reducers: {
        signIn: (state) => {
          state.isSignedIn = true
        },
        signOut: (state) => {
          state.isSignedIn = false
          state.token = null
          state.user = null
        },
        clearError: (state) => {
          state.error = null
        }
      },
      extraReducers: (builder) => {
        // Login cases
        builder.addCase(loginUser.pending, (state) => {
          state.isLoading = true
          state.error = null
        })
        builder.addCase(loginUser.fulfilled, (state, action) => {
          state.isLoading = false
          state.isSignedIn = true
          state.token = action.payload.token
          state.user = action.payload.user
          state.error = null
        })
        builder.addCase(loginUser.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })

        // Logout cases
        builder.addCase(logoutUser.pending, (state) => {
          state.isLoading = true
        })
        builder.addCase(logoutUser.fulfilled, (state) => {
          state.isLoading = false
          state.isSignedIn = false
          state.token = null
          state.user = null
          state.error = null
        })
        builder.addCase(logoutUser.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })

        // Check auth status cases
        builder.addCase(checkAuthStatus.pending, (state) => {
          state.isLoading = true
        })
        builder.addCase(checkAuthStatus.fulfilled, (state, action) => {
          state.isLoading = false
          if (action.payload) {
            state.isSignedIn = true
            state.token = action.payload.token
            state.user = action.payload.user
          } else {
            state.isSignedIn = false
            state.token = null
            state.user = null
          }
          state.error = null
        })
        builder.addCase(checkAuthStatus.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })
      }
    })

    export const { signIn, signOut, clearError } = userSlice.actions;
    export default userSlice.reducer;
  TSX
end

# Auth service
create_file "app/frontend/services/authService.ts" do
  <<~TS
    // Authentication service for handling API calls
    export interface LoginCredentials {
      email: string;
      password: string;
    }

    export interface AuthResponse {
      token: string;
      user: {
        id: number;
        email: string;
        // Add other user fields as needed
      };
      expires_in?: number;
    }

    export interface ApiError {
      message: string;
      status?: number;
    }

    class AuthService {
      private baseURL = '/api/v1';

      async login(credentials: LoginCredentials): Promise<AuthResponse> {
        try {
          const response = await fetch(`${this.baseURL}/users/sign_in`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ user: credentials }),
          });

          if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `Login failed with status ${response.status}`);
          }

          const data: AuthResponse = await response.json();
          return data;
        } catch (error) {
          if (error instanceof Error) {
            throw new Error(error.message);
          }
          throw new Error('An unexpected error occurred during login');
        }
      }

      async logout(): Promise<void> {
        try {
          const response = await fetch(`${this.baseURL}/users/sign_out`, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
            },
          });

          if (!response.ok) {
            throw new Error(`Logout failed with status ${response.status}`);
          }
        } catch (error) {
          console.error('Logout error:', error);
          // Even if logout fails, we should clear local auth state
          throw error;
        }
      }

      async validateToken(token: string): Promise<boolean> {
        try {
          const response = await fetch(`${this.baseURL}/users/validate_token`, {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
          });

          console.log('Token validation response status:', response.status);
          if (!response.ok) {
            console.log('Token validation failed with status:', response.status);
            return false;
          }
          return true;
        } catch (error) {
          console.error('Token validation error:', error);
          return false;
        }
      }

      // Helper method to set authorization header for future requests
      setAuthHeader(token: string): void {
        // This can be used to configure fetch defaults if needed
        // For now, we'll handle headers in each request
      }
    }

    export const authService = new AuthService();
  TS
end

# Token storage
create_file "app/frontend/services/tokenStorage.ts" do
  <<~TS
    // Token storage service with encryption and security features

    export interface TokenStorageOptions {
      encrypt?: boolean;
      storageType: 'local' | 'session';
    }

    class TokenStorage {
      private readonly TOKEN_KEY = 'auth_token';
      private readonly STORAGE_TYPE_KEY = 'auth_storage_type';
      private encryptionKey: CryptoKey | null = null;

      // Initialize encryption if needed
      async initializeEncryption(): Promise<void> {
        if (typeof window !== 'undefined' && window.crypto) {
          try {
            this.encryptionKey = await crypto.subtle.generateKey(
              {
                name: 'AES-GCM',
                length: 256,
              },
              true,
              ['encrypt', 'decrypt']
            );
          } catch (error) {
            console.warn('Web Crypto API not available, falling back to plain text storage');
            this.encryptionKey = null;
          }
        }
      }

      // Encrypt token using Web Crypto API
      private async encryptToken(token: string): Promise<string> {
        if (!this.encryptionKey) {
          return token; // Fallback to plain text if encryption is not available
        }

        try {
          const encoder = new TextEncoder();
          const data = encoder.encode(token);
          const iv = crypto.getRandomValues(new Uint8Array(12));
          
          const encrypted = await crypto.subtle.encrypt(
            {
              name: 'AES-GCM',
              iv: iv,
            },
            this.encryptionKey,
            data
          );

          // Combine IV and encrypted data for storage
          const combined = new Uint8Array(iv.length + encrypted.byteLength);
          combined.set(iv, 0);
          combined.set(new Uint8Array(encrypted), iv.length);

          return btoa(String.fromCharCode(...combined));
        } catch (error) {
          console.error('Encryption failed:', error);
          return token; // Fallback to plain text
        }
      }

      // Decrypt token using Web Crypto API
      private async decryptToken(encryptedToken: string): Promise<string> {
        if (!this.encryptionKey) {
          return encryptedToken; // Return as is if encryption was not used
        }

        try {
          const combined = Uint8Array.from(atob(encryptedToken), c => c.charCodeAt(0));
          const iv = combined.slice(0, 12);
          const encryptedData = combined.slice(12);

          const decrypted = await crypto.subtle.decrypt(
            {
              name: 'AES-GCM',
              iv: iv,
            },
            this.encryptionKey,
            encryptedData
          );

          const decoder = new TextDecoder();
          return decoder.decode(decrypted);
        } catch (error) {
          console.error('Decryption failed:', error);
          return encryptedToken; // Return as is if decryption fails
        }
      }

      // Store token with specified storage type
      async storeToken(token: string, options: TokenStorageOptions): Promise<void> {
        await this.initializeEncryption();
        
        let tokenToStore = token;
        if (options.encrypt && this.encryptionKey) {
          tokenToStore = await this.encryptToken(token);
        }

        const storage = options.storageType === 'local' ? localStorage : sessionStorage;
        
        storage.setItem(this.TOKEN_KEY, tokenToStore);
        localStorage.setItem(this.STORAGE_TYPE_KEY, options.storageType);
      }

      // Retrieve token from storage
      async getToken(): Promise<string | null> {
        await this.initializeEncryption();
        
        // Check both storage locations
        let encryptedToken = localStorage.getItem(this.TOKEN_KEY) || sessionStorage.getItem(this.TOKEN_KEY);
        
        if (!encryptedToken) {
          return null;
        }

        // Get storage type to determine if encryption was used
        const storageType = localStorage.getItem(this.STORAGE_TYPE_KEY) as 'local' | 'session' | null;
        
        if (storageType && this.encryptionKey) {
          try {
            return await this.decryptToken(encryptedToken);
          } catch (error) {
            console.error('Failed to decrypt token:', error);
            return encryptedToken; // Return encrypted token as fallback
          }
        }

        return encryptedToken;
      }

      // Clear token from all storage locations
      clearToken(): void {
        localStorage.removeItem(this.TOKEN_KEY);
        sessionStorage.removeItem(this.TOKEN_KEY);
        localStorage.removeItem(this.STORAGE_TYPE_KEY);
      }

      // Get the storage type used for the current token
      getStorageType(): 'local' | 'session' | null {
        return localStorage.getItem(this.STORAGE_TYPE_KEY) as 'local' | 'session' | null;
      }

      // Check if a token exists
      hasToken(): boolean {
        return !!(localStorage.getItem(this.TOKEN_KEY) || sessionStorage.getItem(this.TOKEN_KEY));
      }
    }

    export const tokenStorage = new TokenStorage();
  TS
end

# ProtectedRoute
create_file "app/frontend/components/ProtectedRoute.tsx" do
  <<~TSX
    import React, { useEffect, useState } from 'react';
    import { Navigate } from 'react-router-dom';
    import { useSelector } from 'react-redux';
    import { RootState } from '../state/store';

    interface ProtectedRouteProps {
      children: React.ReactNode;
    }

    const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
      const isSignedIn = useSelector((state: RootState) => state.user.isSignedIn);
      const isLoading = useSelector((state: RootState) => state.user.isLoading);
      const [authChecked, setAuthChecked] = useState(false);

      useEffect(() => {
        if (!isLoading) {
          setAuthChecked(true);
        }
      }, [isLoading]);

      if (isLoading || !authChecked) {
        return (
          <div className="flex items-center justify-center h-screen bg-slate-50">
            <div className="flex flex-col items-center gap-3">
              <div className="w-10 h-10 border-[3px] border-teal-600 border-t-transparent rounded-full animate-spin" />
              <p className="text-sm font-medium text-slate-400 tracking-wide">Loading...</p>
            </div>
          </div>
        );
      }

      if (!isSignedIn) {
        return <Navigate to="/login" replace />;
      }

      return <>{children}</>;
    };

    export default ProtectedRoute;
  TSX
end

# LoginForm
create_file "app/frontend/components/auth/LoginForm.tsx" do
  <<~TSX
    import React, { useState } from 'react';
    import { useDispatch, useSelector } from 'react-redux';
    import { AppDispatch, RootState } from '../../state/store';
    import { loginUser, clearError } from '../../state/user/userSlice';
    import { tokenStorage } from '../../services/tokenStorage';
    import { Mail, Lock, ArrowRight, AlertCircle, Eye, EyeOff } from 'lucide-react';

    interface LoginFormProps {
      onSuccess: () => void;
    }

    const LoginForm: React.FC<LoginFormProps> = ({ onSuccess }) => {
      const dispatch = useDispatch<AppDispatch>();
      const { isLoading, error } = useSelector((state: RootState) => state.user);

      const [email, setEmail] = useState('');
      const [password, setPassword] = useState('');
      const [rememberMe, setRememberMe] = useState(false);
      const [showPassword, setShowPassword] = useState(false);
      const [localError, setLocalError] = useState<string | null>(null);

      const displayError = localError || error;

      const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLocalError(null);
        dispatch(clearError());

        const result = await dispatch(loginUser({ email, password }));

        if (loginUser.fulfilled.match(result)) {
          await tokenStorage.storeToken(result.payload.token, {
            encrypt: true,
            storageType: rememberMe ? 'local' : 'session',
          });
          onSuccess();
        } else if (loginUser.rejected.match(result)) {
          setLocalError((result.payload as string) || 'Invalid email or password.');
        }
      };

      return (
        <div className="space-y-6">
          <div>
            <h2 className="text-2xl font-bold text-slate-900 tracking-tight">Sign in to your account</h2>
            <p className="mt-1.5 text-sm text-slate-500">Enter your credentials to access the dashboard.</p>
          </div>

          {displayError && (
            <div className="flex items-start gap-3 px-4 py-3 rounded-xl bg-red-50 border border-red-200 text-red-700">
              <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" />
              <p className="text-sm font-medium">{displayError}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <label htmlFor="email" className="block text-xs font-semibold text-slate-600 uppercase tracking-wider">
                Email address
              </label>
              <div className="relative">
                <Mail className="absolute w-4 h-4 text-slate-400 top-1/2 -translate-y-1/2 left-3.5 pointer-events-none" />
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={isLoading}
                  placeholder="you@company.com"
                  className="w-full pl-10 pr-4 py-2.5 text-sm text-slate-800 bg-slate-50 border border-slate-200 rounded-xl placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:bg-white focus:border-transparent transition-all duration-150 disabled:opacity-50"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label htmlFor="password" className="block text-xs font-semibold text-slate-600 uppercase tracking-wider">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute w-4 h-4 text-slate-400 top-1/2 -translate-y-1/2 left-3.5 pointer-events-none" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={isLoading}
                  placeholder="••••••••"
                  className="w-full pl-10 pr-10 py-2.5 text-sm text-slate-800 bg-slate-50 border border-slate-200 rounded-xl placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:bg-white focus:border-transparent transition-all duration-150 disabled:opacity-50"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((prev) => !prev)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                  tabIndex={-1}
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center gap-2.5 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  disabled={isLoading}
                  className="w-4 h-4 text-teal-600 bg-slate-100 border-slate-300 rounded focus:ring-teal-500 focus:ring-offset-0 cursor-pointer"
                />
                <span className="text-sm text-slate-600">Remember me</span>
              </label>
              <button type="button" className="text-sm font-semibold text-teal-600 hover:text-teal-700 transition-colors duration-150">
                Forgot password?
              </button>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="group relative flex items-center justify-center w-full px-4 py-2.5 mt-2 text-sm font-semibold text-white bg-teal-600 rounded-xl hover:bg-teal-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 disabled:opacity-60 disabled:cursor-not-allowed transition-all duration-150 shadow-lg shadow-teal-600/30"
            >
              {isLoading ? (
                <span className="flex items-center gap-2">
                  <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z" />
                  </svg>
                  Signing in...
                </span>
              ) : (
                <span className="flex items-center gap-2">
                  Sign in
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-0.5 transition-transform duration-150" />
                </span>
              )}
            </button>
          </form>
        </div>
      );
    };

    export default LoginForm;
  TSX
end

# Login page
create_file "app/frontend/pages/login/index.tsx" do
  <<~TSX
    import React from 'react';
    import { useNavigate } from 'react-router-dom';
    import LoginForm from '../../components/auth/LoginForm';
    import { Zap, BarChart2, ShieldCheck, Users, Globe } from 'lucide-react';

    const features = [
      { icon: BarChart2, label: 'Real-time analytics & reporting' },
      { icon: ShieldCheck, label: 'Enterprise-grade JWT security' },
      { icon: Users, label: 'Role-based access control' },
      { icon: Globe, label: 'Global infrastructure & 99.9% uptime' },
    ];

    const LoginPage: React.FC = () => {
      const navigate = useNavigate();

      const handleLoginSuccess = () => {
        navigate('/');
      };

      return (
        <div className="flex h-screen overflow-hidden">
          {/* Left brand panel */}
          <div className="hidden lg:flex lg:w-[58%] relative flex-col justify-between p-12 overflow-hidden bg-gradient-to-br from-slate-950 via-teal-950 to-slate-950">
            {/* Animated orbs */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
              <div className="absolute -top-32 -left-32 w-[420px] h-[420px] rounded-full bg-teal-500/20 blur-3xl animate-float" />
              <div className="absolute -bottom-32 -right-32 w-[380px] h-[380px] rounded-full bg-cyan-500/15 blur-3xl animate-float-delayed" />
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[280px] h-[280px] rounded-full bg-teal-400/10 blur-3xl" />
            </div>

            {/* Dot grid overlay */}
            <div
              className="absolute inset-0 pointer-events-none opacity-[0.07]"
              style={{ backgroundImage: 'radial-gradient(circle, #fff 1px, transparent 1px)', backgroundSize: '28px 28px' }}
            />

            {/* Top: logo */}
            <div className="relative z-10 flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-teal-600 flex items-center justify-center shadow-lg shadow-teal-900/60">
                <Zap className="w-5 h-5 text-white" />
              </div>
              <span className="text-white text-lg font-bold tracking-tight">AppName</span>
            </div>

            {/* Middle: hero copy */}
            <div className="relative z-10 space-y-8">
              <div className="space-y-4">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-teal-500/20 border border-teal-500/30">
                  <span className="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse" />
                  <span className="text-teal-300 text-xs font-semibold tracking-widest uppercase">Now with AI insights</span>
                </div>
                <h1 className="text-[2.6rem] font-extrabold text-white leading-[1.15] tracking-tight">
                  Everything you need,<br />
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 via-cyan-300 to-emerald-400">
                    in one platform.
                  </span>
                </h1>
                <p className="text-slate-400 text-base leading-relaxed max-w-sm">
                  Manage your team, track performance, and grow your business with powerful enterprise tools.
                </p>
              </div>

              <div className="space-y-3">
                {features.map(({ icon: Icon, label }) => (
                  <div key={label} className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-slate-800/60 border border-slate-700/50 flex items-center justify-center shrink-0">
                      <Icon className="w-4 h-4 text-teal-400" />
                    </div>
                    <span className="text-slate-300 text-sm">{label}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Bottom: social proof */}
            <div className="relative z-10 flex items-center gap-4">
              <div className="flex -space-x-2">
                {['#0D9488', '#8B5CF6', '#06B6D4', '#F59E0B'].map((color, i) => (
                  <div
                    key={i}
                    className="w-7 h-7 rounded-full border-2 border-slate-900 flex items-center justify-center text-[10px] font-bold text-white"
                    style={{ backgroundColor: color }}
                  >
                    {['JD', 'AM', 'CK', 'TR'][i]}
                  </div>
                ))}
              </div>
              <p className="text-slate-400 text-xs">
                Trusted by <span className="text-slate-200 font-semibold">10,000+</span> teams worldwide
              </p>
            </div>
          </div>

          {/* Right form panel */}
          <div className="flex-1 flex flex-col items-center justify-center bg-white px-8 py-12 overflow-y-auto">
            {/* Mobile-only logo */}
            <div className="lg:hidden flex items-center gap-2.5 mb-10">
              <div className="w-8 h-8 rounded-xl bg-teal-600 flex items-center justify-center">
                <Zap className="w-4 h-4 text-white" />
              </div>
              <span className="text-slate-900 text-base font-bold tracking-tight">AppName</span>
            </div>

            <div className="w-full max-w-sm">
              <LoginForm onSuccess={handleLoginSuccess} />

              <p className="mt-8 text-center text-sm text-slate-400">
                Don't have an account?{' '}
                <button className="font-semibold text-teal-600 hover:text-teal-700 transition-colors duration-150">
                  Contact your administrator
                </button>
              </p>
            </div>

            <p className="mt-12 text-xs text-slate-300">
              © {new Date().getFullYear()} AppName. All rights reserved.
            </p>
          </div>
        </div>
      );
    };

    export default LoginPage;
  TSX
end

# Home page
create_file "app/frontend/pages/home/index.tsx" do
  <<~TSX
    import React, { useRef, useState, useEffect } from 'react';
    import { useDispatch, useSelector } from 'react-redux';
    import { logoutUser } from '../../state/user/userSlice';
    import { RootState } from '../../state/store';
    import {
      LayoutDashboard, User, Settings, LogOut, Bell,
      ChevronDown, Zap, TrendingUp, Users, ShoppingCart,
      DollarSign, ArrowUpRight, ArrowDownRight, Menu, X,
      ArrowRight, UserPlus, BarChart2, ShieldCheck, Key,
    } from 'lucide-react';

    const statCards = [
      {
        label: 'Total Revenue',
        value: '$48,295',
        change: '+12.5%',
        up: true,
        icon: DollarSign,
        gradient: 'from-teal-500 to-cyan-400',
        shadow: 'shadow-teal-500/20',
        iconBg: 'bg-teal-500/10',
        iconColor: 'text-teal-500',
      },
      {
        label: 'Active Users',
        value: '3,842',
        change: '+8.1%',
        up: true,
        icon: Users,
        gradient: 'from-violet-500 to-purple-600',
        shadow: 'shadow-violet-500/20',
        iconBg: 'bg-violet-500/10',
        iconColor: 'text-violet-500',
      },
      {
        label: 'New Orders',
        value: '1,209',
        change: '-3.2%',
        up: false,
        icon: ShoppingCart,
        gradient: 'from-amber-500 to-orange-500',
        shadow: 'shadow-amber-500/20',
        iconBg: 'bg-amber-500/10',
        iconColor: 'text-amber-500',
      },
      {
        label: 'Growth Rate',
        value: '24.6%',
        change: '+4.9%',
        up: true,
        icon: TrendingUp,
        gradient: 'from-sky-500 to-blue-500',
        shadow: 'shadow-sky-500/20',
        iconBg: 'bg-sky-500/10',
        iconColor: 'text-sky-500',
      },
    ];

    const activities = [
      { title: 'New user registered', desc: 'sarah.chen@company.com joined the platform', time: '2m ago', icon: UserPlus, iconBg: 'bg-teal-50', iconColor: 'text-teal-600', dot: 'bg-teal-500' },
      { title: 'Order #1042 completed', desc: '$299 — Pro plan annual subscription', time: '47m ago', icon: ShoppingCart, iconBg: 'bg-emerald-50', iconColor: 'text-emerald-600', dot: 'bg-emerald-500' },
      { title: 'Monthly report ready', desc: 'March 2026 analytics report generated', time: '2h ago', icon: BarChart2, iconBg: 'bg-violet-50', iconColor: 'text-violet-600', dot: 'bg-violet-500' },
      { title: 'System backup succeeded', desc: 'All 12 databases backed up successfully', time: '3h ago', icon: ShieldCheck, iconBg: 'bg-amber-50', iconColor: 'text-amber-600', dot: 'bg-amber-500' },
      { title: 'New API key created', desc: 'Production environment — expires in 90 days', time: '5h ago', icon: Key, iconBg: 'bg-slate-100', iconColor: 'text-slate-600', dot: 'bg-slate-400' },
    ];

    const performanceMetrics = [
      { label: 'Conversion Rate', pct: 68, gradient: 'from-teal-500 to-cyan-400' },
      { label: 'User Retention', pct: 84, gradient: 'from-violet-500 to-purple-600' },
      { label: 'Goal Completion', pct: 52, gradient: 'from-amber-500 to-orange-500' },
      { label: 'Revenue Target', pct: 79, gradient: 'from-sky-500 to-blue-500' },
    ];

    const navItems = [
      { label: 'Dashboard', icon: LayoutDashboard, active: true },
      { label: 'Users', icon: Users, active: false },
      { label: 'Profile', icon: User, active: false },
      { label: 'Settings', icon: Settings, active: false },
    ];

    const StatCard: React.FC<typeof statCards[0]> = ({ label, value, change, up, icon: Icon, gradient, shadow, iconBg, iconColor }) => (
      <div className={`bg-white rounded-2xl p-5 border border-slate-100 shadow-md ${shadow} hover:-translate-y-1 hover:shadow-lg transition-all duration-200 cursor-default`}>
        <div className="flex items-start justify-between">
          <div className={`w-10 h-10 rounded-xl ${iconBg} flex items-center justify-center`}>
            <Icon className={`w-5 h-5 ${iconColor}`} />
          </div>
          <span className={`inline-flex items-center gap-0.5 text-xs font-semibold px-2 py-1 rounded-full ${up ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-500'}`}>
            {up ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
            {change}
          </span>
        </div>
        <div className="mt-4">
          <p className="text-2xl font-bold text-slate-900 tracking-tight">{value}</p>
          <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">{label}</p>
        </div>
        <div className={`mt-4 h-1 w-full rounded-full bg-gradient-to-r ${gradient} opacity-80`} />
      </div>
    );

    const HomePage: React.FC = () => {
      const dispatch = useDispatch();
      const user = useSelector((state: RootState) => state.user.user);
      const [dropdownOpen, setDropdownOpen] = useState(false);
      const [sidebarOpen, setSidebarOpen] = useState(false);
      const dropdownRef = useRef<HTMLDivElement>(null);

      const handleLogout = () => { dispatch(logoutUser() as any); };

      const initials = user?.email ? user.email.slice(0, 2).toUpperCase() : 'U';
      const firstName = user?.email?.split('@')[0] ?? 'there';
      const hour = new Date().getHours();
      const timeOfDay = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
      const today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });

      useEffect(() => {
        const handleClickOutside = (e: MouseEvent) => {
          if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) setDropdownOpen(false);
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
      }, []);

      return (
        <div className="flex h-screen bg-slate-50 overflow-hidden">
          {sidebarOpen && (
            <div className="fixed inset-0 bg-black/50 z-20 lg:hidden backdrop-blur-sm" onClick={() => setSidebarOpen(false)} />
          )}

          {/* Sidebar */}
          <aside className={`fixed lg:static inset-y-0 left-0 z-30 w-64 bg-slate-900 flex flex-col shrink-0 transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
            <div className="h-14 flex items-center justify-between px-5 border-b border-slate-700/50 shrink-0">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl bg-teal-600 flex items-center justify-center shadow-lg shadow-teal-900/60">
                  <Zap className="w-4 h-4 text-white" />
                </div>
                <span className="text-white font-bold text-base tracking-tight">AppName</span>
              </div>
              <button onClick={() => setSidebarOpen(false)} className="lg:hidden p-1 text-slate-500 hover:text-slate-300 transition-colors">
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="px-5 pt-5 pb-2">
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-[0.12em]">Main Menu</p>
            </div>

            <nav className="flex-1 px-3 space-y-0.5 overflow-y-auto">
              {navItems.map(({ label, icon: Icon, active }) => (
                <button
                  key={label}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors duration-150 text-left ${active ? 'bg-teal-600/15 text-teal-400 border-l-2 border-teal-500 pl-[10px]' : 'text-slate-400 hover:bg-slate-800 hover:text-slate-100 border-l-2 border-transparent pl-[10px]'}`}
                >
                  <Icon className="w-4 h-4 shrink-0" />
                  {label}
                  {active && <span className="ml-auto w-1.5 h-1.5 rounded-full bg-teal-400" />}
                </button>
              ))}
            </nav>

            <div className="p-3 border-t border-slate-700/50 shrink-0">
              <div className="flex items-center gap-3 px-2 py-2 rounded-lg hover:bg-slate-800 transition-colors group">
                <div className="w-8 h-8 rounded-lg bg-teal-600 flex items-center justify-center text-xs font-bold text-white shrink-0">{initials}</div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold text-slate-300 truncate">{user?.email}</p>
                  <p className="text-[10px] text-slate-500 font-medium">Administrator</p>
                </div>
                <button onClick={handleLogout} title="Sign out" className="p-1 text-slate-500 hover:text-red-400 transition-colors opacity-0 group-hover:opacity-100">
                  <LogOut className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          </aside>

          {/* Main */}
          <div className="flex-1 flex flex-col min-w-0">
            <header className="h-14 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-6 shrink-0 shadow-sm">
              <div className="flex items-center gap-3">
                <button onClick={() => setSidebarOpen(true)} className="lg:hidden p-2 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors">
                  <Menu className="w-5 h-5" />
                </button>
                <div>
                  <h1 className="text-sm font-bold text-slate-900 leading-tight">Dashboard</h1>
                  <p className="text-[11px] text-slate-400 hidden sm:block">{today}</p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button className="relative p-2 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors duration-150">
                  <Bell className="w-4.5 h-4.5" />
                  <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-red-500 rounded-full ring-2 ring-white" />
                </button>

                <div className="relative" ref={dropdownRef}>
                  <button
                    onClick={() => setDropdownOpen((prev) => !prev)}
                    aria-expanded={dropdownOpen}
                    className="flex items-center gap-2 pl-1 pr-2.5 py-1.5 rounded-xl border border-slate-200 hover:bg-slate-50 transition-colors duration-150"
                  >
                    <div className="w-7 h-7 rounded-lg bg-teal-600 flex items-center justify-center text-[11px] font-bold text-white shrink-0">{initials}</div>
                    <span className="text-sm font-medium text-slate-700 max-w-[140px] truncate hidden sm:block">{user?.email}</span>
                    <ChevronDown className={`w-3.5 h-3.5 text-slate-400 shrink-0 transition-transform duration-150 ${dropdownOpen ? 'rotate-180' : ''}`} />
                  </button>

                  {dropdownOpen && (
                    <div className="absolute right-0 mt-2 w-56 bg-white rounded-xl border border-slate-200 shadow-xl shadow-slate-200/80 overflow-hidden z-50">
                      <div className="px-4 py-3 border-b border-slate-100 bg-slate-50">
                        <p className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider">Signed in as</p>
                        <p className="text-sm font-semibold text-slate-800 truncate mt-0.5">{user?.email}</p>
                      </div>
                      <div className="py-1">
                        <button className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-slate-700 hover:bg-slate-50 transition-colors">
                          <User className="w-4 h-4 text-slate-400 shrink-0" />Profile
                        </button>
                        <button className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-slate-700 hover:bg-slate-50 transition-colors">
                          <Settings className="w-4 h-4 text-slate-400 shrink-0" />Settings
                        </button>
                      </div>
                      <div className="border-t border-slate-100 py-1">
                        <button onClick={handleLogout} className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors">
                          <LogOut className="w-4 h-4 shrink-0" />Sign out
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </header>

            <main className="flex-1 overflow-y-auto p-4 lg:p-6 space-y-5">
              {/* Welcome banner */}
              <div className="relative rounded-2xl overflow-hidden bg-gradient-to-r from-slate-950 via-teal-950 to-slate-950 animate-gradient-shift">
                <div className="absolute inset-0 pointer-events-none">
                  <div className="absolute -top-16 -right-16 w-64 h-64 rounded-full bg-teal-500/25 blur-3xl" />
                  <div className="absolute -bottom-16 left-1/4 w-48 h-48 rounded-full bg-cyan-500/20 blur-3xl" />
                  <div className="absolute inset-0 opacity-[0.04]" style={{ backgroundImage: 'radial-gradient(circle, #fff 1px, transparent 1px)', backgroundSize: '24px 24px' }} />
                </div>
                <div className="relative z-10 px-6 py-6 lg:px-8 lg:py-7">
                  <p className="text-teal-400 text-xs font-semibold uppercase tracking-widest mb-1">Overview</p>
                  <h2 className="text-xl lg:text-2xl font-bold text-white tracking-tight">
                    Good {timeOfDay}, <span className="text-teal-300">{firstName}</span> 👋
                  </h2>
                  <p className="text-slate-400 text-sm mt-1.5 max-w-md">Your platform is running smoothly. Here's a summary of today's activity.</p>
                  <button className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-teal-600 hover:bg-teal-500 text-white text-sm font-semibold transition-all duration-150 shadow-lg shadow-teal-900/40 group">
                    View full report
                    <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform duration-150" />
                  </button>
                </div>
              </div>

              {/* Stat cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                {statCards.map((card) => <StatCard key={card.label} {...card} />)}
              </div>

              {/* Bottom row */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
                <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                  <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                    <h3 className="text-sm font-bold text-slate-900">Recent Activity</h3>
                    <button className="flex items-center gap-1 text-xs font-semibold text-teal-600 hover:text-teal-700 transition-colors group">
                      View all<ArrowRight className="w-3 h-3 group-hover:translate-x-0.5 transition-transform" />
                    </button>
                  </div>
                  <div className="divide-y divide-slate-50">
                    {activities.map((a, i) => (
                      <div key={i} className="flex items-center gap-4 px-6 py-3.5 hover:bg-slate-50/70 transition-colors">
                        <div className={`w-9 h-9 rounded-xl ${a.iconBg} flex items-center justify-center shrink-0`}>
                          <a.icon className={`w-4 h-4 ${a.iconColor}`} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-semibold text-slate-800 truncate">{a.title}</p>
                          <p className="text-xs text-slate-400 truncate">{a.desc}</p>
                        </div>
                        <div className="flex items-center gap-2 shrink-0">
                          <span className={`w-1.5 h-1.5 rounded-full ${a.dot}`} />
                          <span className="text-xs text-slate-400">{a.time}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                  <div className="px-6 py-4 border-b border-slate-100">
                    <h3 className="text-sm font-bold text-slate-900">Performance</h3>
                    <p className="text-xs text-slate-400 mt-0.5">vs. previous month</p>
                  </div>
                  <div className="p-6 space-y-5">
                    {performanceMetrics.map((m) => (
                      <div key={m.label}>
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-xs font-semibold text-slate-600">{m.label}</span>
                          <span className="text-xs font-bold text-slate-800">{m.pct}%</span>
                        </div>
                        <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                          <div className={`h-full rounded-full bg-gradient-to-r ${m.gradient}`} style={{ width: `${m.pct}%` }} />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </main>
          </div>
        </div>
      );
    };

    export default HomePage;
  TSX
end

# ── Rails backend ─────────────────────────────────────────────
say "== Setting up Rails backend ==", :green

# ApplicationController
remove_file "app/controllers/application_controller.rb"
create_file "app/controllers/application_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
    end
  RUBY
end

# RootController
create_file "app/controllers/root_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class RootController < ApplicationController
      def index
      end
    end
  RUBY
end

create_file "app/views/root/index.html.erb", ""

# API controllers
empty_directory "app/controllers/api/v1/users"

create_file "app/controllers/api/v1/users/sessions_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class Api::V1::Users::SessionsController < Devise::SessionsController
      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)

        render json: {
          status: { 
            code: 200, message: 'Logged in successfully.',
            data: { user: UserBlueprint.render_as_hash(current_user) }
          }
        }, status: :ok
      end

      def destroy
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        
        if signed_out
          render json: {
            status: 200,
            message: 'Logged out successfully.'
          }, status: :ok
        else
          render json: {
            status: 422,
            message: "There was a problem logging out."
          }, status: :unproccessable_entity
        end
      end
      
      def respond_with(current_user, _opts = {})
        render json: {
          status: { 
            code: 200, message: 'Logged in successfully.',
            data: { user: UserBlueprint.render_as_hash(current_user) }
          }
        }, status: :ok
      end

      # Add token validation endpoint
      def validate_token
        if current_user
          render json: {
            status: { 
              code: 200, message: 'Token is valid.',
              data: { user: UserBlueprint.render_as_hash(current_user) }
            }
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Invalid or expired token."
          }, status: :unauthorized
        end
      end
    end
  RUBY
end

create_file "app/controllers/api/v1/users/registrations_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
      def respond_with(current_user, _opts = {})
        if resource.persisted?
          render json: {
            status: {code: 200, message: 'Signed up successfully.'},
            data: UserBlueprint.render_as_hash(current_user)
          }
        else
          render json: {
            message: "User couldn't be created successfully. \#{current_user.errors.full_messages.to_sentence}"
          }, status: :unprocessable_entity
        end
      end
    end
  RUBY
end

# Blueprint
empty_directory "app/blueprints"
create_file "app/blueprints/user_blueprint.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class UserBlueprint < Blueprinter::Base
      identifier :id

      fields :email
    end
  RUBY
end

# ── Phase 1 routes: skeleton only — no devise_for, no draw(:api) ──
# Generators (devise:install, devise User) boot Rails to introspect routes.
# If devise_for :users or draw(:api) are present at that point, Rails calls
# const_get('User') before the model exists and crashes. The full routes are
# written in after_bundle (Phase 2) once the User model and DB are ready.
remove_file "config/routes.rb"
create_file "config/routes.rb" do
  <<~RUBY
    # frozen_string_literal: true

    Rails.application.routes.draw do
      get 'up' => 'rails/health#show', as: :rails_health_check
    end
  RUBY
end

empty_directory "config/routes"

# CORS initializer
create_file "config/initializers/cors.rb" do
  <<~RUBY
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # later change to the domain of the frontend app
        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 expose: [:Authorization]
      end
    end
  RUBY
end

# RSwag initializers
create_file "config/initializers/rswag_api.rb" do
  <<~RUBY
    Rswag::Api.configure do |c|

      # Specify a root folder where Swagger JSON files are located
      # This is used by the Swagger middleware to serve requests for API descriptions
      # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
      # that it's configured to generate files in the same folder
      c.openapi_root = Rails.root.to_s + '/swagger'

      # Inject a lambda function to alter the returned Swagger prior to serialization
      # The function will have access to the rack env for the current request
      # For example, you could leverage this to dynamically assign the "host" property
      #
      #c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
    end
  RUBY
end

create_file "config/initializers/rswag_ui.rb" do
  <<~RUBY
    Rswag::Ui.configure do |c|

      # List the Swagger endpoints that you want to be documented through the
      # swagger-ui. The first parameter is the path (absolute or relative to the UI
      # host) to the corresponding endpoint and the second is a title that will be
      # displayed in the document selector.
      # NOTE: If you're using rspec-api to expose Swagger files
      # (under openapi_root) as JSON or YAML endpoints, then the list below should
      # correspond to the relative paths for those endpoints.

      c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'

      # Add Basic Auth in case your API is private
      # c.basic_auth_enabled = true
      # c.basic_auth_credentials 'username', 'password'
    end
  RUBY
end

# ── Devise + JWT ──────────────────────────────────────────────
say "== Installing Devise ==", :green
run "bundle exec rails generate devise:install"

say "== Generating User model with Devise ==", :green
run "bundle exec rails generate devise User"

# Add JTI to users
run "bundle exec rails generate migration AddJtiToUsers jti:string:uniq:not_null"

# Overwrite User model with JWT support
remove_file "app/models/user.rb"
create_file "app/models/user.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class User < ApplicationRecord
      # Include default devise modules. Others available are:
      # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
      include Devise::JWT::RevocationStrategies::JTIMatcher
      
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable,
             :jwt_authenticatable, jwt_revocation_strategy: self

      validates :email, presence: true
    end
  RUBY
end

# ── Phase 2 routes: written immediately after generators ─────
# Devise generators are done — User model exists on disk.
# Overwrite the skeleton routes.rb and write config/routes/*.rb now,
# in the main template body (not after_bundle) so they are reliably applied.
say "== Writing full routes (Phase 2) ==", :green

create_file "config/routes.rb", force: true do
  <<~RUBY
    # frozen_string_literal: true

    Rails.application.routes.draw do
      mount Rswag::Api::Engine => '/api-docs'
      mount Rswag::Ui::Engine => '/api-docs'
      draw(:api)

      get 'up' => 'rails/health#show', as: :rails_health_check

      get '/*anyPath', to: 'root#index', anyPath: /(?!api).*/
    end
  RUBY
end

create_file "config/routes/api.rb" do
  <<~RUBY
    # frozen_string_literal: true

    namespace :api do
      draw(:v1)
    end
  RUBY
end

create_file "config/routes/v1.rb" do
  <<~RUBY
    # frozen_string_literal: true

    namespace :v1 do
      draw(:devise)
    end
  RUBY
end

create_file "config/routes/devise.rb" do
  <<~RUBY
    # frozen_string_literal: true

    devise_for :users, singular: :user, controllers: {
      registrations: 'api/v1/users/registrations',
      sessions: 'api/v1/users/sessions'
    }

    # Add custom route for token validation
    devise_scope :user do
      get 'users/validate_token', to: 'users/sessions#validate_token'
    end
  RUBY
end

# ── RSpec ─────────────────────────────────────────────────────
say "== Installing RSpec ==", :green
run "bundle exec rails generate rspec:install"

# rails_helper additions
inject_into_file "spec/rails_helper.rb", after: "require 'rspec/rails'\n" do
  <<~RUBY
    require_relative 'support/factory_bot'
    require_relative 'support/shoulda_matchers'
  RUBY
end

inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do
  "  config.include Devise::Test::IntegrationHelpers, type: :request\n"
end

# Support files
empty_directory "spec/support"
create_file "spec/support/factory_bot.rb" do
  <<~RUBY
    # frozen_string_literal: true
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY
end

create_file "spec/support/shoulda_matchers.rb" do
  <<~RUBY
    # frozen_string_literal: true
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  RUBY
end

# User factory
create_file "spec/factories/users.rb" do
  <<~RUBY
    # frozen_string_literal: true

    FactoryBot.define do
      factory :user do
        email { Faker::Internet.email }
        password { SecureRandom.hex }
      end
    end
  RUBY
end

# User model spec
create_file "spec/models/user_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'rails_helper'

    RSpec.describe User do
      describe '#validations' do
        it { is_expected.to validate_presence_of(:email) }
      end
    end
  RUBY
end

create_file "spec/blueprints/user_blueprint_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true
    require 'rails_helper'
    require './spec/support/shared_examples/blueprints/blueprint'

    RSpec.describe UserBlueprint do
      describe '#render' do
        let(:record) { create(:user) }

        it_behaves_like 'a blueprint' do
          let(:expected_keys) { %i[email id] }
        end
      end
    end
  RUBY
end

create_file "spec/requests/api/v1/users/registrations_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'swagger_helper'

    RSpec.describe 'Registrations' do
      let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

      describe '#create' do # rubocop:disable RSpec/EmptyExampleGroup
        path '/api/v1/users' do
          post 'registers new users' do
            tags 'Registrations'
            consumes 'application/json'
            parameter name: :params, in: :body, schema: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string },
                password_confirmation: { type: :string },
              }
            }

            response(200, 'register new user successfully') do
              let(:params) do
                {
                  user: {
                    email: 'sample@email.com',
                    password: '12345678',
                    password_confirmation: '12345678'
                  }
                }
              end

              run_test! do |response|
                expect(response).to have_http_status :ok
                expect(json_response).to include(
                  data: include(email: 'sample@email.com'),
                  status: include(code: 200, message: 'Signed up successfully.')
                )
              end
            end

            response(422, 'registration failed because email is malformed') do
              let(:params) do
                {
                  user: {
                    email: 'sample.com',
                    password: '12345678',
                    password_confirmation: '12345678'
                  }
                }
              end

              run_test! do |response|
                expect(response).to have_http_status :unprocessable_entity
                expect(json_response).to include(
                  message: "User couldn't be created successfully. Email is invalid"
                )
              end
            end

            response(422, 'registration failed because passwords do not match') do
              let(:params) do
                {
                  user: {
                    email: 'sample@email.com',
                    password: '12345678',
                    password_confirmation: '123456789'
                  }
                }
              end

              run_test! do |response|
                expect(response).to have_http_status :unprocessable_entity
                expect(json_response).to include(
                  message: "User couldn't be created successfully. Password confirmation doesn't match Password"
                )
              end
            end

            response(422, 'registration failed because user already exists') do
              let(:params) do
                {
                  user: {
                    email: 'sample@email.com',
                    password: '12345678',
                    password_confirmation: '12345678'
                  }
                }
              end

              before do
                create(:user, email: 'sample@email.com', password: '12345678', password_confirmation: '12345678')
              end

              run_test! do |response|
                expect(response).to have_http_status :unprocessable_entity
                expect(json_response).to include(
                  message: "User couldn't be created successfully. Email has already been taken"
                )
              end
            end
          end
        end
      end
    end
  RUBY
end

create_file "spec/requests/api/v1/users/sessions_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'swagger_helper'

    RSpec.describe 'Sessions' do
      let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

      describe '#create' do # rubocop:disable RSpec/EmptyExampleGroup
        path '/api/v1/users/sign_in' do
          post 'creates new user session' do
            tags 'Sessions'
            consumes 'application/json'
            parameter name: :params, in: :body, schema: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string },
              }
            }

            response(200, 'logins new user successfully') do
              let(:params) do
                {
                  user: {
                    email: 'sample@email.com',
                    password: '12345678',
                  }
                }
              end

              before do
                create(:user, email: 'sample@email.com', password: '12345678')
              end

              run_test! do |response|
                expect(response).to have_http_status :ok
                expect(json_response).to include(
                  status: include(
                    code: 200,
                    data: include(
                      user: include(email: 'sample@email.com')
                    ),
                    message: 'Logged in successfully.',
                  )
                )
              end
            end
          end
        end
      end

      describe '#destroy' do # rubocop:disable RSpec/EmptyExampleGroup
        path '/api/v1/users/sign_out' do
          delete 'logs out user' do
            tags 'Sessions'
            consumes 'application/json'

            response(200, 'logouts new user successfully') do
              let(:user) do
                create(
                  :user,
                  email: 'test@email.com',
                  password: 'password',
                  password_confirmation: 'password'
                )
              end

              before do
                sign_in user
              end

              run_test! do |response|
                expect(response).to have_http_status :ok
                expect(json_response).to include(
                  message: 'Logged out successfully.',
                  status: 200
                )
              end
            end
          end
        end
      end

      describe '#validate_token' do # rubocop:disable RSpec/EmptyExampleGroup
        path '/api/v1/users/validate_token' do
          get 'validates user token' do
            tags 'Sessions'
            consumes 'application/json'

            response(200, 'validates user token') do
              let(:user) do
                create(
                  :user,
                  email: 'test@email.com',
                  password: 'password',
                  password_confirmation: 'password'
                )
              end

              before do
                sign_in user
              end

              run_test! do |response|
                expect(response).to have_http_status :ok
              end
            end

            response(401, 'validates user token if it doesn not exist') do
              run_test! do |response|
                expect(response).to have_http_status :unauthorized
              end
            end
          end
        end
      end
    end
  RUBY
end

create_file "spec/routing/users/sessions_routing_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'rails_helper'

    RSpec.describe 'Sessions Routing' do
      describe '#new' do
        subject { get('/api/v1/users/sign_in') }

        it { is_expected.to route_to(controller: 'api/v1/users/sessions', action: 'new') }
      end

      describe '#create' do
        subject { post('/api/v1/users/sign_in') }

        it { is_expected.to route_to(controller: 'api/v1/users/sessions', action: 'create') }
      end

      describe '#destroy' do
        subject { delete('/api/v1/users/sign_out') }

        it { is_expected.to route_to(controller: 'api/v1/users/sessions', action: 'destroy') }
      end

      describe '#validate_token' do
        subject { get('/api/v1/users/validate_token') }

        it { is_expected.to route_to(controller: 'api/v1/users/sessions', action: 'validate_token') }
      end
    end
  RUBY
end

create_file "spec/support/shared_examples/blueprints/blueprint.rb" do
  <<~RUBY
    # frozen_string_literal: true
    RSpec.shared_examples 'a blueprint' do
      let(:custom_attributes) { {} }
      let(:stringifiable_keys) { {} }
      let(:result) do
        JSON.parse(described_class.render(record), symbolize_names: true)
      end
      let(:stringified_values) do
        stringifiable_keys.index_with do |key|
          record[key].to_s
        end
      end
      describe '#render' do
        it 'renders the correct body' do #rubocop:disable RSpec/ExampleLength
          attributes = if record.respond_to?(:attributes)
                         record.attributes
                       elsif record.respond_to?(:to_h)
                         record.to_h
                       else
                         JSON.parse(record.to_json, symbolize_names: true)
                       end
          expect(result.keys).to match_array(expected_keys)
          expect(result).to match(
            attributes
              .symbolize_keys
              .slice(*expected_keys)
              .merge(
                custom_attributes,
                stringified_values
              )
          )
        end
      end
    end
  RUBY
end

create_file "spec/swagger_helper.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'rails_helper'

    RSpec.configure do |config|
      # Specify a root folder where Swagger JSON files are generated
      # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
      # to ensure that it's configured to serve Swagger from the same folder
      config.openapi_root = Rails.root.join('swagger').to_s

      # Define one or more Swagger documents and provide global metadata for each one
      # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
      # be generated at the provided relative path under openapi_root
      # By default, the operations defined in spec files are added to the first
      # document below. You can override this behavior by adding a openapi_spec tag to the
      # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
      config.openapi_specs = {
        'v1/swagger.yaml' => {
          openapi: '3.0.1',
          info: {
            title: 'API V1',
            version: 'v1'
          },
          paths: {},
          servers: [
            {
              url: 'https://{defaultHost}',
              variables: {
                defaultHost: {
                  default: 'www.example.com'
                }
              }
            }
          ]
        }
      }

      # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
      # The openapi_specs configuration option has the filename including format in
      # the key, this may want to be changed to avoid putting yaml in json files.
      # Defaults to json. Accepts ':json' and ':yaml'.
      config.openapi_format = :yaml
    end
  RUBY
end

# ── Swagger scaffold ──────────────────────────────────────────
empty_directory "swagger/v1"
create_file "swagger/v1/swagger.yaml" do
  <<~YAML
    ---
    openapi: 3.0.1
    info:
      title: API V1
      version: v1
    paths:
      "/api/v1/users":
        post:
          summary: registers new users
          tags:
          - Registrations
          parameters: []
          responses:
            '200':
              description: register new user successfully
            '422':
              description: registration failed because user already exists
          requestBody:
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    email:
                      type: string
                    password:
                      type: string
                    password_confirmation:
                      type: string
      "/api/v1/users/sign_in":
        post:
          summary: creates new user session
          tags:
          - Sessions
          parameters: []
          responses:
            '200':
              description: logins new user successfully
          requestBody:
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    email:
                      type: string
                    password:
                      type: string
      "/api/v1/users/sign_out":
        delete:
          summary: logs out user
          tags:
          - Sessions
          parameters:
          - name: Authorization
            in: header
            schema:
              type: string
          responses:
            '200':
              description: logins new user successfully
    servers:
    - url: https://{defaultHost}
      variables:
        defaultHost:
          default: www.example.com
  YAML
end

# ── DB + credentials + JWT config ────────────────────────────
# Strict order required:
#   1. DB created + migrated — migrations are on disk, no initializer JWT yet
#   2. Credential written — no KeyError when initializer loads next
#   3. JWT config appended — bang method safe, credential is present
say "== Creating and migrating database ==", :green
run "bin/rails db:create"
run "bin/rails db:migrate"

say "== Writing devise_jwt_secret_key credential ==", :green
# Rails 8.1: credentials.write requires the content as an argument.
# Use File.write/delete directly to avoid create_file tracking.
credential_script = File.join(destination_root, "tmp/write_credential.rb")
File.write(credential_script, <<~RUBY)
  current = Rails.application.credentials.read.to_s.chomp
  secret  = SecureRandom.hex(64)
  Rails.application.credentials.write(current + "\\ndevise_jwt_secret_key: " + secret + "\\n")
RUBY
rails_command "runner tmp/write_credential.rb"
File.delete(credential_script)

say "== Appending JWT config to Devise initializer ==", :green
append_to_file "config/initializers/devise.rb" do
  <<~RUBY

    Devise.setup do |config|
      config.jwt do |jwt|
        jwt.secret = Rails.application.credentials.devise_jwt_secret_key!
        jwt.dispatch_requests = [
          ['POST', %r{^/login$}]
        ]
        jwt.revocation_requests = [
          ['DELETE', %r{^/logout$}]
        ]
        jwt.expiration_time = 5.minutes.to_i
      end
    end
  RUBY
end

# ── Final instructions ────────────────────────────────────────
say "", :green
say "================================================================", :green
say "  Template applied successfully!", :green
say "================================================================", :green
say ""
say "Next steps:"
say "  1. Start the dev server:"
say "     bin/dev  (requires Foreman: gem install foreman)"
say "  2. Rename the app:"
say "     rails app:rename[MyNewAppName]"
say ""
say "  (db:create, db:migrate, and credentials were set up automatically)"
say ""
say "URLs:"
say "  App:     http://localhost:3000"
say "  API docs: http://localhost:3000/api-docs"
say ""
