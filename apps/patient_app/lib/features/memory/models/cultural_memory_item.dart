/// Represents a culturally familiar item from the North Eastern Region (NER).
///
/// Categories:
/// - Food
/// - Music
/// - Festivals
/// - Clothing
/// - Places
/// - Household Objects
/// - Stories
///
/// Strictly non-clinical, respectful, and curated demo content set.
class CulturalMemoryItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final String? image;
  final String language;
  final String region;
  final int difficulty;
  final String prompt;
  final List<String> answerOptions;
  final String correctAnswer;

  const CulturalMemoryItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.image,
    this.language = 'en',
    required this.region,
    this.difficulty = 1,
    required this.prompt,
    required this.answerOptions,
    required this.correctAnswer,
  });

  /// Small, authentic demo content set representing traditions from across the North East.
  /// Clearly labeled as curated sample items for demo exploration.
  static const List<CulturalMemoryItem> demoItems = [
    CulturalMemoryItem(
      id: 'ner_c_jaapi',
      category: 'Household Objects',
      title: 'Assamese Jaapi',
      description: 'A traditional conical headgear crafted from tightly woven bamboo and palm leaves, decorated with red and green cloth.',
      region: 'Assam',
      language: 'en',
      prompt: 'What is this traditional conical woven headgear, presented as a mark of respect?',
      answerOptions: ['Jaapi', 'Kula', 'Paan Bota', 'Dokhona'],
      correctAnswer: 'Jaapi',
    ),
    CulturalMemoryItem(
      id: 'ner_c_bihu',
      category: 'Festivals',
      title: 'Rongali Bihu',
      description: 'The vibrant spring festival of Assam celebrating the Assamese New Year, music, and harvest rhythms.',
      region: 'Assam',
      language: 'en',
      prompt: 'Which spring festival of Assam welcomes the New Year with rhythmic dhol and pepa music?',
      answerOptions: ['Rongali Bihu', 'Wangala', 'Hornbill', 'Chapchar Kut'],
      correctAnswer: 'Rongali Bihu',
    ),
    CulturalMemoryItem(
      id: 'ner_c_pitha',
      category: 'Food',
      title: 'Til Pitha',
      description: 'Crispy rice flour roll filled with roasted black sesame seeds and liquid jaggery, enjoyed during festive gatherings.',
      region: 'Assam',
      language: 'en',
      prompt: 'What is this festive rice-flour roll stuffed with roasted sesame and sweet jaggery?',
      answerOptions: ['Til Pitha', 'Jadoh', 'Momos', 'Axone'],
      correctAnswer: 'Til Pitha',
    ),
    CulturalMemoryItem(
      id: 'ner_c_cheraw',
      category: 'Music',
      title: 'Cheraw Bamboo Dance',
      description: 'A rhythmic and graceful dance of Mizoram performed using 4 to 8 crossed bamboo staves tapped together.',
      region: 'Mizoram',
      language: 'en',
      prompt: 'Which graceful folk dance of Mizoram is performed by stepping between tapping bamboo poles?',
      answerOptions: ['Cheraw', 'Bihu Dance', 'Thabal Chongba', 'Shad Suk Mynsiem'],
      correctAnswer: 'Cheraw',
    ),
    CulturalMemoryItem(
      id: 'ner_c_wangala',
      category: 'Festivals',
      title: 'Wangala 100 Drums',
      description: 'The harvest thanksgiving festival of the Garo people of Meghalaya, known as the 100 Drums Festival.',
      region: 'Meghalaya',
      language: 'en',
      prompt: 'Which Garo harvest festival of Meghalaya is celebrated with the rhythm of 100 long drums?',
      answerOptions: ['Wangala', 'Sangai', 'Sekrenyi', 'Moatsu'],
      correctAnswer: 'Wangala',
    ),
    CulturalMemoryItem(
      id: 'ner_c_shawl',
      category: 'Clothing',
      title: 'Traditional Naga Shawl',
      description: 'Warm hand-woven woollen shawl featuring bold red, black, and white patterns representing heritage.',
      region: 'Nagaland',
      language: 'en',
      prompt: 'What is this hand-woven traditional shawl with distinctive geometric red and black stripes?',
      answerOptions: ['Naga Shawl', 'Gamosa', 'Innaphi', 'Ryndia Silk'],
      correctAnswer: 'Naga Shawl',
    ),
    CulturalMemoryItem(
      id: 'ner_c_loktak',
      category: 'Places',
      title: 'Loktak Lake & Phumdis',
      description: 'The iconic freshwater lake of Manipur famous for its floating circular islands called phumdis.',
      region: 'Manipur',
      language: 'en',
      prompt: 'Which famous freshwater lake in Manipur is known for unique floating islands called phumdis?',
      answerOptions: ['Loktak Lake', 'Umiam Lake', 'Rudrasagar', 'Tam Dil'],
      correctAnswer: 'Loktak Lake',
    ),
  ];
}
