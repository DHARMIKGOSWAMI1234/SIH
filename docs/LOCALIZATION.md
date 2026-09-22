# SMRITI — Multilingual Localization System (Phase 07)

## 1. Overview & Language Count

SMRITI strictly supports **9 languages** of India and the North Eastern Region (NER). There is NO 10th language.

The 9 supported languages are:

| # | Language | ISO Code | Script | Native Name | Status |
|---|---|---|---|---|---|
| 1 | **English** | `en` | Latin | English | **Fully Translation-Verified** |
| 2 | **Hindi** | `hi` | Devanagari | हिन्दी | **Fully Translation-Verified** |
| 3 | **Assamese** | `as` | Bengali-Assamese | অসমীয়া | **Fully Translation-Verified** |
| 4 | **Bengali** | `bn` | Bengali | বাংলা | Architecturally Supported / Translation Review Required |
| 5 | **Meitei / Manipuri** | `mni` | Meetei Mayek / Bengali | মৈতৈলোন | Architecturally Supported / Translation Review Required |
| 6 | **Bodo** | `brx` | Devanagari | बर' | Architecturally Supported / Translation Review Required |
| 7 | **Mizo** | `lus` | Latin | Mizo | Architecturally Supported / Translation Review Required |
| 8 | **Khasi** | `kha` | Latin | Khasi | Architecturally Supported / Translation Review Required |
| 9 | **Garo** | `grt` | Latin | Garo | Architecturally Supported / Translation Review Required |

> [!IMPORTANT]
> **Clinical & Elderly Verification Standard**:
> - Only English, Hindi, and Assamese have undergone complete semantic verification for elderly cognitive care.
> - The remaining 6 languages (`bn`, `mni`, `brx`, `lus`, `kha`, `grt`) are architecturally integrated into the localized dictionary, route structure, and font fallback chains, but are flagged in the UI with a `*` and `Requires Translation Review` badge to prevent fabricated translation claims.

---

## 2. Architecture & Fallback Safety

```
User selects Language
        ↓
LocaleNotifier (Flutter) / LocalizationContext (React)
        ↓
Check Dictionary: _localizedValues[locale]
        ├── Key exists & not empty? → Use localized string
        └── Key missing or unreviewed?
                    ↓
        Deterministic Fallback:
        Look up in 'en' (English)
                    ↓
        Key exists in 'en'? → Use English string
                    ↓
        Key missing in 'en'? → Return key identifier (never null, blank, or broken)
```

### Safety Guarantees
1. **Never Blank or Null**: Missing or empty keys always fall back to English.
2. **No App Restarts**: Changing language triggers a reactive rebuild across the widget tree (`LocaleNotifier` $\rightarrow$ `notifyListeners()`).
3. **Local Persistence**: Selected language persists in `AuthStorage` (`smriti_pref_language`) and synchronizes with the patient's remote profile upon network availability.
4. **Preservation of Personal User Content**: User-created memory stories, personal titles, family member names, locations, and caregiver notes are preserved strictly in their entered language and are NEVER auto-translated.

---

## 3. Implementation in Flutter (`apps/patient_app`)

- **Dictionary**: `lib/l10n/app_strings.dart`
- **Provider**: `lib/l10n/locale_notifier.dart`
- **Supported Locales**: Registered in `MaterialApp` via `supportedLocales` and `localizationsDelegates`.
- **UI Selector**: Accessible in `SettingsScreen` and during registration in `LoginScreen`.

---

## 4. Implementation in Caregiver Dashboard (`apps/caregiver_dashboard`)

- **Dictionary**: `src/l10n/translations.ts`
- **Context & Hook**: `src/context/LocalizationContext.tsx` (`useTranslation`)
- **TopBar Selector**: Dynamic `<select>` element in `TopBar.tsx` reflecting active language and review status badges.
