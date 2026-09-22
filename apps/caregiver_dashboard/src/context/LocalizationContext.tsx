import React, { createContext, useContext, useState } from 'react';
import { SUPPORTED_LANGUAGES, LanguageMeta, translations } from '../l10n/translations';

interface LocalizationContextType {
  currentLanguage: string;
  setLanguage: (code: string) => void;
  languages: LanguageMeta[];
  t: (key: string) => string;
}

const LocalizationContext = createContext<LocalizationContextType | undefined>(undefined);

const STORAGE_KEY = 'smriti_caregiver_lang';

export const LocalizationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentLanguage, setCurrentLanguage] = useState<string>(() => {
    return localStorage.getItem(STORAGE_KEY) || 'en';
  });

  const setLanguage = (code: string) => {
    if (SUPPORTED_LANGUAGES.some((l) => l.code === code)) {
      setCurrentLanguage(code);
      localStorage.setItem(STORAGE_KEY, code);
    }
  };

  const t = (key: string): string => {
    const langMap = translations[currentLanguage];
    if (langMap && langMap[key]) {
      return langMap[key];
    }
    // Fallback to English
    const enMap = translations['en'];
    if (enMap && enMap[key]) {
      return enMap[key];
    }
    return key;
  };

  return (
    <LocalizationContext.Provider
      value={{
        currentLanguage,
        setLanguage,
        languages: SUPPORTED_LANGUAGES,
        t,
      }}
    >
      {children}
    </LocalizationContext.Provider>
  );
};

export const useTranslation = () => {
  const context = useContext(LocalizationContext);
  if (!context) {
    throw new Error('useTranslation must be used within a LocalizationProvider');
  }
  return context;
};
