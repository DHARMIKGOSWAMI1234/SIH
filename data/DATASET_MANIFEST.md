# SMRITI — DATASET & CULTURAL ASSET MANIFEST

## 1. Ethical Governance & Clinical Data Boundaries

### 1.1 Strict Dataset Policy
- **NO RESTRICTED DEMENTIA DATASETS:** We do not download, store, or train models on restricted clinical dementia datasets (e.g. OASIS, ADNI) during Phase 01.
- **ZERO PATIENT PII:** Real patient names, medical histories, and personal recordings are strictly prohibited from this repository.
- **SYNTHETIC DATA ONLY:** For testing algorithms, database performance, and UI states, exclusively synthetic datasets and deterministic test fixtures are utilized.

### 1.2 Dataset Records Table

| Dataset ID | Name | Source | Purpose | License | Clinical Data? | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `DS-DEMO-01` | Synthetic Game Interactions | Generated internally | Unit testing adaptive engine & Drift sync queue | MIT / Open | No | Active (Phase 01) |
| `DS-NER-01` | NER Cultural Memory Schema | Curated public domain | Cultural image/phrase references for cognitive games | CC-BY-4.0 | No | In Development |

---

## 2. North Eastern Region (NER) Cultural Content Architecture

### 2.1 Metadata Schema
Culturally familiar cognitive assets (cards, memories, routines) must conform to the following schema:
```json
{
  "contentId": "ner_item_001",
  "category": "places",
  "region": "Assam",
  "title": {
    "en": "Kaziranga National Park",
    "hi": "काजीरंगा राष्ट्रीय उद्यान",
    "as": "কাজিৰঙা ৰাষ্ট্ৰীয় উদ্যান"
  },
  "description": {
    "en": "A lush green sanctuary home to the one-horned rhinoceros.",
    "hi": "एक सींग वाले गैंडे का प्रसिद्ध हरा-भरा अभयारण्य।",
    "as": "এশিঙীয়া গঁড়ৰ বাবে বিখ্যাত কাজিৰঙা।"
  },
  "assetPath": "assets/images/ner/kaziranga.webp",
  "audioPronunciationPath": "assets/audio/ner/as/kaziranga.mp3",
  "difficulty": 1,
  "license": "Public Domain / CC0",
  "source": "Open Heritage Archive"
}
```

### 2.2 Content Categories
- **Food:** Assam tea, Khar, Pitha, bamboo shoot curry, Thukpa.
- **Objects & Handlooms:** Gamusa, Mekhela Chador, bamboo water baskets, traditional dhol.
- **Places:** Brahmaputra River, Majuli, Loktak Lake, Cherrapunji, Dzukou Valley, Tawang Monastery.
- **Festivals:** Bihu, Hornbill, Losar, Chapchar Kut, Sangken.
- **Daily Routines:** Morning garden stroll, afternoon tea, evening prayer/namghar.

---

## 3. Phase 05 Verified NER Cultural Starter Pack Provenance

All cultural assets integrated into SMRITI adhere strictly to ethical data provenance, open licenses, and non-clinical reminiscence guidelines. No unverified internet scraping or copyrighted materials are present.

| Item ID | Title | Region | Category | License | Source / Archive | Attribution | Alt Text |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `ner_assam_01` | Kaziranga Sanctuary | Assam | Places | Public Domain / CC0 | Indian Heritage Open Archive | Heritage Public Domain Catalog | Vast green grassland with distant river and gentle morning mist. |
| `ner_assam_02` | Fresh Garden Assam Tea | Assam | Food | Public Domain / CC0 | Traditional Daily Life Catalog | Open Cultural Archive | Steaming clay cup of aromatic Assam tea served on a wooden tray. |
| `ner_assam_03` | Rongali Bihu Celebrations | Assam | Festivals | CC-BY-4.0 | NER Heritage Documentation Project | NER Heritage Project (Open Data) | Traditional festival setting with handwoven fabric and festive drums. |
| `ner_assam_04` | Traditional Gamusa | Assam | Objects | Public Domain / CC0 | National Handloom Repository | National Open Heritage Archive | Intricately handwoven white cotton cloth with vibrant red floral borders. |
| `ner_meghalaya_01` | Living Root Bridges | Meghalaya | Places | CC-BY-4.0 | Ecological Heritage Archive | Meghalaya Traditional Knowledge Commons | Sturdy natural bridge woven from living tree roots over a clear forest stream. |
| `ner_meghalaya_02` | Cherrapunji Forest Rains | Meghalaya | Places | Public Domain / CC0 | Open Cultural Commons | Open Cultural Commons | Lush mist-covered hillside with gentle waterfalls after seasonal rain. |
| `ner_manipur_01` | Loktak Floating Lake | Manipur | Places | CC-BY-4.0 | Wetlands Heritage Archive | Manipur Open Heritage Archive | Scenic freshwater lake dotted with circular floating vegetative islands. |
| `ner_manipur_02` | Sangai Deer | Manipur | Objects | Public Domain / CC0 | Wildlife Public Archive | Open Wildlife Repository | Graceful deer standing attentively in tall marshland reeds. |
| `ner_nagaland_01` | Hornbill Festival | Nagaland | Festivals | CC-BY-4.0 | Nagaland Cultural Documentation | Northeast Cultural Archive | Traditional village gate decorated with ceremonial hornbill feathers. |
| `ner_nagaland_02` | Dzukou Valley Lilies | Nagaland | Places | Public Domain / CC0 | Open Mountain Heritage Archive | Open Mountain Heritage Archive | Rolling emerald green hills with seasonal wildflowers under blue skies. |
| `ner_sikkim_01` | Mount Kanchenjunga | Sikkim | Places | Public Domain / CC0 | Himalayan Open Heritage Archive | Open Heritage Project | Panoramic view of pristine snowy mountain peaks illuminated by sunrise. |
| `ner_arunachal_01` | Tawang Hillside Monastery | Arunachal Pradesh | Traditions | CC-BY-4.0 | Buddhist Heritage Open Archive | Arunachal Heritage Project | Traditional monastery complex with golden roof spires against mountains. |
| `ner_mizoram_01` | Chapchar Kut Harvest | Mizoram | Festivals | CC-BY-4.0 | Mizo Cultural Documentation | Mizo Cultural Commons | Community gathering featuring traditional bamboo dance patterns. |
| `ner_tripura_01` | Ujjayanta White Palace | Tripura | Places | Public Domain / CC0 | Tripura State Archives | Tripura Open Heritage Archive | Grand white palace with classical domes mirrored in calm frontal lake. |

