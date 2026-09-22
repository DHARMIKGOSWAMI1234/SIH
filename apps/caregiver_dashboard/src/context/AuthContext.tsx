import React, { createContext, useContext, useState, useEffect } from 'react';
import { caregiverApi, AuthUser } from '../api/client';

interface AuthContextType {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: {
    email: string;
    password: string;
    full_name: string;
    relationship_to_patient?: string;
    phone_number?: string;
  }) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('smriti_caregiver_token'));
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const logout = () => {
    localStorage.removeItem('smriti_caregiver_token');
    caregiverApi.setToken(null);
    setToken(null);
    setUser(null);
  };

  useEffect(() => {
    caregiverApi.onUnauthorized = logout;
  }, []);

  useEffect(() => {
    const initAuth = async () => {
      if (token) {
        caregiverApi.setToken(token);
        try {
          const profile = await caregiverApi.getMe();
          if (profile) {
            setUser(profile);
          } else {
            logout();
          }
        } catch {
          // If server unavailable, preserve session or logout
        }
      }
      setIsLoading(false);
    };

    initAuth();
  }, [token]);

  const login = async (email: string, password: string) => {
    const res = await caregiverApi.login(email, password);
    localStorage.setItem('smriti_caregiver_token', res.access_token);
    caregiverApi.setToken(res.access_token);
    setToken(res.access_token);
    const profile = await caregiverApi.getMe();
    if (profile) {
      setUser(profile);
    }
  };

  const register = async (data: {
    email: string;
    password: string;
    full_name: string;
    relationship_to_patient?: string;
    phone_number?: string;
  }) => {
    const res = await caregiverApi.register(data);
    localStorage.setItem('smriti_caregiver_token', res.access_token);
    caregiverApi.setToken(res.access_token);
    setToken(res.access_token);
    const profile = await caregiverApi.getMe();
    if (profile) {
      setUser(profile);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!token && !!user,
        isLoading,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
