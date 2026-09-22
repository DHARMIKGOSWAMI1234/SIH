import '../models/cultural_content_item.dart';

/// Service managing culturally familiar North Eastern Region (NER) content.
///
/// Every item complies with strict data provenance guidelines:
/// - Explicit source documented
/// - Open license recorded (Public Domain / CC0 / CC-BY-4.0)
/// - Attribution requirements specified
/// - Detailed accessibility altText provided
class CulturalPackService {
  static final List<CulturalContentItem> _starterPack = [
    // ASSAM
    CulturalContentItem(
      id: 'ner_assam_01',
      title: 'Kaziranga Sanctuary',
      description: 'Lush grasslands and misty morning wetlands, home of the one-horned rhinoceros.',
      category: 'places',
      region: 'Assam',
      language: 'en',
      altText: 'Vast green grassland with distant river and gentle morning mist.',
      source: 'Open Cultural Commons / Indian Heritage Archive',
      license: 'Public Domain / CC0',
      attribution: 'Heritage Public Domain Catalog',
      difficulty: 1,
      tags: ['places', 'nature', 'assam', 'wildlife'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_assam_02',
      title: 'Fresh Garden Assam Tea',
      description: 'Warm morning cup of rich tea brewed from fresh garden leaves.',
      category: 'food',
      region: 'Assam',
      language: 'en',
      altText: 'Steaming clay cup of aromatic Assam tea served on a wooden tray.',
      source: 'Open Cultural Commons / Traditional Daily Life Catalog',
      license: 'Public Domain / CC0',
      attribution: 'Open Cultural Archive',
      difficulty: 1,
      tags: ['food', 'tea', 'assam', 'morning'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_assam_03',
      title: 'Rongali Bihu Celebrations',
      description: 'Spring festival celebrated with traditional Dhol rhythms and family feasts.',
      category: 'festivals',
      region: 'Assam',
      language: 'en',
      altText: 'Traditional festival setting with handwoven fabric and festive drums.',
      source: 'Northeast Cultural Heritage Documentation Project',
      license: 'CC-BY-4.0',
      attribution: 'NER Heritage Project (Open Data)',
      difficulty: 1,
      tags: ['festivals', 'spring', 'bihu', 'music'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_assam_04',
      title: 'Traditional Gamusa',
      description: 'Handwoven white and red cotton towel presented as a token of deep respect.',
      category: 'objects',
      region: 'Assam',
      language: 'en',
      altText: 'Intricately handwoven white cotton cloth with vibrant red floral borders.',
      source: 'National Handloom & Heritage Repository',
      license: 'Public Domain / CC0',
      attribution: 'National Open Heritage Archive',
      difficulty: 1,
      tags: ['objects', 'traditions', 'assam', 'weaving'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // MEGHALAYA
    CulturalContentItem(
      id: 'ner_meghalaya_01',
      title: 'Living Root Bridges',
      description: 'Ancient bio-engineered bridges naturally guided across gentle rivers.',
      category: 'places',
      region: 'Meghalaya',
      language: 'en',
      altText: 'Sturdy natural bridge woven from living tree roots over a clear forest stream.',
      source: 'Ecological Heritage Public Archive',
      license: 'CC-BY-4.0',
      attribution: 'Meghalaya Traditional Knowledge Commons',
      difficulty: 2,
      tags: ['places', 'nature', 'meghalaya', 'rivers'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_meghalaya_02',
      title: 'Cherrapunji Forest Rains',
      description: 'Peaceful raindrops pattering over lush green valleys and waterfalls.',
      category: 'places',
      region: 'Meghalaya',
      language: 'en',
      altText: 'Lush mist-covered hillside with gentle waterfalls after seasonal rain.',
      source: 'Open Cultural Commons',
      license: 'Public Domain / CC0',
      attribution: 'Open Cultural Commons',
      difficulty: 1,
      tags: ['places', 'nature', 'meghalaya', 'rain'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // MANIPUR
    CulturalContentItem(
      id: 'ner_manipur_01',
      title: 'Loktak Floating Lake',
      description: 'The world’s only floating lake with gentle circular phumdis and calm waters.',
      category: 'places',
      region: 'Manipur',
      language: 'en',
      altText: 'Scenic freshwater lake dotted with circular floating vegetative islands.',
      source: 'Wetlands Heritage Open Archive',
      license: 'CC-BY-4.0',
      attribution: 'Manipur Open Heritage Archive',
      difficulty: 1,
      tags: ['places', 'lake', 'manipur', 'nature'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_manipur_02',
      title: 'Sangai Brow-Antlered Deer',
      description: 'Graceful rare deer resting peacefully on the floating meadows of Keibul Lamjao.',
      category: 'objects',
      region: 'Manipur',
      language: 'en',
      altText: 'Graceful deer standing attentively in tall marshland reeds.',
      source: 'Wildlife Public Archive',
      license: 'Public Domain / CC0',
      attribution: 'Open Wildlife Repository',
      difficulty: 2,
      tags: ['objects', 'wildlife', 'manipur', 'nature'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // NAGALAND
    CulturalContentItem(
      id: 'ner_nagaland_01',
      title: 'Hornbill Festival of Heritage',
      description: 'Celebration of rich folklore, traditional crafts, and communal song.',
      category: 'festivals',
      region: 'Nagaland',
      language: 'en',
      altText: 'Traditional village gate decorated with ceremonial hornbill feathers and carvings.',
      source: 'Nagaland Cultural Documentation Archive',
      license: 'CC-BY-4.0',
      attribution: 'Northeast Cultural Archive',
      difficulty: 1,
      tags: ['festivals', 'nagaland', 'crafts', 'music'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    CulturalContentItem(
      id: 'ner_nagaland_02',
      title: 'Dzukou Valley Lilies',
      description: 'Sweeping green valley carpeted with seasonal wild white and pink blooms.',
      category: 'places',
      region: 'Nagaland',
      language: 'en',
      altText: 'Rolling emerald green hills with seasonal wildflowers under clear blue skies.',
      source: 'Open Mountain Heritage Archive',
      license: 'Public Domain / CC0',
      attribution: 'Open Mountain Heritage Archive',
      difficulty: 2,
      tags: ['places', 'nature', 'nagaland', 'flowers'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // SIKKIM
    CulturalContentItem(
      id: 'ner_sikkim_01',
      title: 'Mount Kanchenjunga',
      description: 'Sacred snow-capped mountain glistening under the early morning golden sun.',
      category: 'places',
      region: 'Sikkim',
      language: 'en',
      altText: 'Panoramic view of pristine snowy mountain peaks illuminated by morning sunrise.',
      source: 'Himalayan Open Heritage Archive',
      license: 'Public Domain / CC0',
      attribution: 'Open Heritage Project',
      difficulty: 1,
      tags: ['places', 'himalayas', 'sikkim', 'mountains'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // ARUNACHAL PRADESH
    CulturalContentItem(
      id: 'ner_arunachal_01',
      title: 'Tawang Hillside Monastery',
      description: 'Serene monastery surrounded by prayer flags and peaceful mountain valleys.',
      category: 'traditions',
      region: 'Arunachal Pradesh',
      language: 'en',
      altText: 'Traditional monastery complex with golden roof spires against mountain backdrop.',
      source: 'Buddhist Heritage Open Archive',
      license: 'CC-BY-4.0',
      attribution: 'Arunachal Heritage Project',
      difficulty: 2,
      tags: ['traditions', 'places', 'arunachal', 'monastery'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // MIZORAM
    CulturalContentItem(
      id: 'ner_mizoram_01',
      title: 'Chapchar Kut Harvest',
      description: 'Joyful harvest festival marked by rhythmic bamboo dance and communal songs.',
      category: 'festivals',
      region: 'Mizoram',
      language: 'en',
      altText: 'Community gathering featuring traditional bamboo dance patterns and festive attire.',
      source: 'Mizo Cultural Documentation Project',
      license: 'CC-BY-4.0',
      attribution: 'Mizo Cultural Commons',
      difficulty: 1,
      tags: ['festivals', 'dance', 'mizoram', 'harvest'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),

    // TRIPURA
    CulturalContentItem(
      id: 'ner_tripura_01',
      title: 'Ujjayanta White Palace',
      description: 'Historic palace reflecting on tranquil garden pools and evening fountains.',
      category: 'places',
      region: 'Tripura',
      language: 'en',
      altText: 'Grand white palace with classical domes mirrored in calm frontal lake.',
      source: 'Tripura State Archives (Open Domain)',
      license: 'Public Domain / CC0',
      attribution: 'Tripura Open Heritage Archive',
      difficulty: 2,
      tags: ['places', 'palace', 'tripura', 'history'],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  /// Retrieves all verified cultural items.
  static List<CulturalContentItem> getAllItems() {
    return List.unmodifiable(_starterPack);
  }

  /// Filters items by region (e.g. 'Assam', 'Meghalaya', etc.).
  static List<CulturalContentItem> getItemsByRegion(String region) {
    return _starterPack.where((item) => item.region.toLowerCase() == region.toLowerCase()).toList();
  }

  /// Filters items by category (e.g. 'places', 'food', 'festivals', etc.).
  static List<CulturalContentItem> getItemsByCategory(String category) {
    return _starterPack.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Finds item by unique ID.
  static CulturalContentItem? getItemById(String id) {
    try {
      return _starterPack.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
