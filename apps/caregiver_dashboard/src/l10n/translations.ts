/**
 * Caregiver Dashboard Multilingual Dictionary.
 * Supports 9 languages of India and the North Eastern Region (NER).
 * Fully verified: English ('en'), Hindi ('hi'), Assamese ('as').
 * Architecturally supported / Translation review required: Bengali ('bn'), Meitei ('mni'), Bodo ('brx'), Mizo ('lus'), Khasi ('kha'), Garo ('grt').
 */

export interface LanguageMeta {
  code: string;
  nativeName: string;
  englishName: string;
  reviewed: boolean;
}

export const SUPPORTED_LANGUAGES: LanguageMeta[] = [
  { code: 'en', nativeName: 'English', englishName: 'English', reviewed: true },
  { code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', reviewed: true },
  { code: 'as', nativeName: 'অসমীয়া', englishName: 'Assamese', reviewed: true },
  { code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', reviewed: false },
  { code: 'mni', nativeName: 'মৈতৈলোন', englishName: 'Meitei / Manipuri', reviewed: false },
  { code: 'brx', nativeName: 'बर\'', englishName: 'Bodo', reviewed: false },
  { code: 'lus', nativeName: 'Mizo', englishName: 'Mizo', reviewed: false },
  { code: 'kha', nativeName: 'Khasi', englishName: 'Khasi', reviewed: false },
  { code: 'grt', nativeName: 'Garo', englishName: 'Garo', reviewed: false },
];

export const translations: Record<string, Record<string, string>> = {
  en: {
    // Navigation
    'nav.overview': 'Overview',
    'nav.patients': 'Patients',
    'nav.activity': 'Activity',
    'nav.memory': 'Memory',
    'nav.reminders': 'Reminders',
    'nav.progress': 'Trends',
    'nav.settings': 'Settings',

    // Header & Actions
    'header.title': 'Caregiver Overview',
    'header.subtitle': 'Monitor recent cognitive activity, routines, and reminders.',
    'header.syncActive': 'Synced',
    'header.patient': 'Patient',
    'header.linkPatient': 'Link',
    'header.signOut': 'Sign Out',
    'header.role': 'CAREGIVER',

    // Link Patient Modal
    'linkModal.title': 'Link Patient Account',
    'linkModal.subtitle': 'Connect with a registered patient using their account email address.',
    'linkModal.emailLabel': 'Patient Email Address *',
    'linkModal.relationshipLabel': 'Relationship to Patient',
    'linkModal.submit': 'Link Patient',
    'linkModal.submitting': 'Linking...',
    'linkModal.cancel': 'Cancel',
    'linkModal.notice': 'Privacy Notice: Server-side authorization enforces that only registered patients can be linked.',

    // Empty states
    'empty.noPatients': 'No Linked Patients Yet',
    'empty.noPatientsDesc': 'Connect to a patient profile using their registered email to view real synchronized activity monitoring.',
    'empty.noSessions': 'No cognitive exercise sessions recorded yet.',
    'empty.noMemories': 'No memories found.',

    // Common
    'common.search': 'Search routines, sessions...',
    'common.status': 'Active & Engaged',
    'common.save': 'Save',
    'common.close': 'Close',
  },

  hi: {
    // Navigation
    'nav.overview': 'अवलोकन',
    'nav.patients': 'मरीज़',
    'nav.activity': 'गतिविधि',
    'nav.memory': 'स्मृति',
    'nav.reminders': 'रिमाइंडर',
    'nav.progress': 'प्रगति',
    'nav.settings': 'सेटिंग्स',

    // Header & Actions
    'header.title': 'देखभालकर्ता अवलोकन',
    'header.subtitle': 'हाल की संज्ञानात्मक गतिविधियों, दिनचर्या और रिमाइंडर की निगरानी।',
    'header.syncActive': 'सिंक हो गया',
    'header.patient': 'मरीज़',
    'header.linkPatient': 'जोड़ें',
    'header.signOut': 'साइन आउट',
    'header.role': 'देखभालकर्ता',

    // Link Patient Modal
    'linkModal.title': 'मरीज़ खाता जोड़ें',
    'linkModal.subtitle': 'मरीज़ के पंजीकृत ईमेल द्वारा उनसे जुड़ें।',
    'linkModal.emailLabel': 'मरीज़ का ईमेल पता *',
    'linkModal.relationshipLabel': 'मरीज़ से संबंध',
    'linkModal.submit': 'मरीज़ जोड़ें',
    'linkModal.submitting': 'जोड़ा जा रहा है...',
    'linkModal.cancel': 'रद्द करें',
    'linkModal.notice': 'गोपनीयता सूचना: केवल पंजीकृत मरीज़ों को ही जोड़ा जा सकता है।',

    // Empty states
    'empty.noPatients': 'अभी कोई मरीज़ नहीं जुड़ा है',
    'empty.noPatientsDesc': 'मरीज़ की वास्तविक समय की गतिविधियों को देखने के लिए उनका ईमेल जोड़ें।',
    'empty.noSessions': 'अभी कोई खेल सत्र रिकॉर्ड नहीं हुआ है।',
    'empty.noMemories': 'कोई याद नहीं मिली।',

    // Common
    'common.search': 'खोजें...',
    'common.status': 'सक्रिय और संलग्न',
    'common.save': 'सहेजें',
    'common.close': 'बंद करें',
  },

  as: {
    // Navigation
    'nav.overview': 'একনজৰত',
    'nav.patients': 'ৰোগী',
    'nav.activity': 'কাৰ্যকলাপ',
    'nav.memory': 'স্মৃতি',
    'nav.reminders': 'সোঁৱৰণি',
    'nav.progress': 'অগ্ৰগতি',
    'nav.settings': 'ছেটিংছ',

    // Header & Actions
    'header.title': 'যত্নশীলৰ বাবে তথ্য একনজৰত',
    'header.subtitle': 'শেহতীয়া স্মৃতি কাৰ্যকলাপ, নিয়ম আৰু সোঁৱৰণি নিৰীক্ষণ।',
    'header.syncActive': 'সংযোগ সম্পন্ন',
    'header.patient': 'ৰোগী',
    'header.linkPatient': 'সংযোগ কৰক',
    'header.signOut': 'প্ৰস্থান',
    'header.role': 'যত্নশীল',

    // Link Patient Modal
    'linkModal.title': 'ৰোগীৰ একাউণ্ট সংযোগ কৰক',
    'linkModal.subtitle': 'ৰোগীৰ পঞ্জীভুক্ত ইমেইল ঠিকনাৰে সংযোগ কৰক।',
    'linkModal.emailLabel': 'ৰোগীৰ ইমেইল ঠিকনা *',
    'linkModal.relationshipLabel': 'ৰোগীৰ সৈতে সম্পৰ্ক',
    'linkModal.submit': 'সংযোগ কৰক',
    'linkModal.submitting': 'সংযোগ হৈ আছে...',
    'linkModal.cancel': 'বাতিল কৰক',
    'linkModal.notice': 'গোপনীয়তাৰ জাননী: কেৱল পঞ্জীভুক্ত ৰোগীকহে সংযোগ কৰিব পাৰি।',

    // Empty states
    'empty.noPatients': 'কোনো ৰোগী সংযোগ কৰা হোৱা নাই',
    'empty.noPatientsDesc': 'ৰোগীৰ অগ্ৰগতি চাবলৈ তেওঁলোকৰ ইমেইল সংযোগ কৰক।',
    'empty.noSessions': 'কোনো খেল তথ্য নাই।',
    'empty.noMemories': 'কোনো স্মৃতি পোৱা নগ’ল।',

    // Common
    'common.search': 'বিচাৰক...',
    'common.status': 'সক্ৰিয় আৰু অংশগ্ৰহণকাৰী',
    'common.save': 'সংৰক্ষণ কৰক',
    'common.close': 'বন্ধ কৰক',
  },

  bn: {
    'nav.overview': 'একনজরে',
    'nav.patients': 'রোগী',
    'nav.activity': 'কার্যক্রমের ইতিহাস',
    'nav.memory': 'স্মৃতি ব্যাংক',
    'nav.reminders': 'অনুস্মারক',
    'nav.progress': 'অগ্রগতি',
    'nav.settings': 'সেটিংস',
    'header.title': 'যত্নকারীর পর্যবেক্ষণ',
    'header.patient': 'রোগী',
    'header.signOut': 'সাইন আউট',
  },

  mni: {
    'nav.overview': 'য়ুম',
    'nav.patients': 'অনাবা',
    'nav.activity': 'শান্নবগী ইতিহাস',
    'nav.memory': 'নিংশিংবা',
    'nav.reminders': 'নিংশিংহল্লকপা',
    'nav.progress': 'চাউখৎপা',
    'nav.settings': 'সেটিংস',
  },

  brx: {
    'nav.overview': 'न\'',
    'nav.patients': 'मरीज',
    'nav.activity': 'गेलेनायनि इतिहास',
    'nav.memory': 'गोसोखांथि',
    'nav.reminders': 'गोसोखांहोग्रा',
    'nav.progress': 'दावगानाय',
    'nav.settings': 'सेटिंस',
  },

  lus: {
    'nav.overview': 'Enchhinna',
    'nav.patients': 'Damlo',
    'nav.activity': 'Thiltih Chanchin',
    'nav.memory': 'Hriatrengna',
    'nav.reminders': 'Hriattirna',
    'nav.progress': 'Hmasawnna',
    'nav.settings': 'Settings',
  },

  'kha': {
    'nav.overview': 'Ka Jingpeit bniah',
    'nav.patients': 'Ki Nongpang',
    'nav.activity': 'Ka Jingkynmaw Jingiaid',
    'nav.memory': 'Ki Jingkynmaw',
    'nav.reminders': 'Ki Jingpynkynmaw',
    'nav.progress': 'Ka Jingroi',
    'nav.settings': 'Ki Settings',
  },

  grt: {
    'nav.overview': 'Ni·ani',
    'nav.patients': 'Sagipa',
    'nav.activity': 'Kamrang',
    'nav.memory': 'Gisik Ra·anirang',
    'nav.reminders': 'Gisik Ra·atgipa',
    'nav.progress': 'Silroroani',
    'nav.settings': 'Settings',
  },
};
