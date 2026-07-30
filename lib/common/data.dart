class AllDataModel {
  static String? selectedPetTypesKey;
  static String? selectedPetBreedsKey;
  static bool checkFirstSeen = false;

  static final Map<String, String> petTypes = {
    'dog': '狗狗',
    'cat': '貓咪',
    'rabbit': '兔子',
    'turtle': '烏龜',
    'other': '其他',
  };

  static List<String> petBreedsList = [];
  static final Map<String, List<String>> petBreeds = {
    'dog': [
      '博美',
      '法鬥',
      '臘腸',
      '貴賓',
      '柯基',
      '柴犬',
      '比熊犬',
      '巴哥犬',
      '米格魯',
      '牧羊犬',
      '哈士奇',
      '吉娃娃',
      '薩摩耶',
      '雪納瑞',
      '約克夏',
      '蝴蝶犬',
      '馬爾濟斯',
      '拉不拉多',
      '黃金獵犬',
      '其他'
    ],
    'cat': [
      '虎斑貓',
      '波斯貓',
      '玳瑁貓',
      '暹羅貓',
      '布偶貓',
      '三色貓',
      '米克斯',
      '曼赤肯貓',
      '美國短毛貓',
      '英國短毛貓',
      '其他'
    ],
    'rabbit': [
      '道奇兔',
      '海棠兔',
      '獅子兔',
      '銀貂兔',
      '香檳兔',
      '奶油兔',
      '銀狐兔',
      '斑點兔',
      '金吉拉兔',
      '安哥拉兔',
      '比利時兔',
      '黃暹羅兔',
      '黑暹羅兔',
      '白暹羅兔',
      '波蘭白兔',
      '雷克斯兔',
      '長毛垂耳兔',
      '短毛垂耳兔',
      '紐西蘭大白兔',
      '其他'
    ],
    'turtle': [
      '蛋龜',
      '擬鱷龜',
      '平胸龜',
      '中華花龜',
      '中華草龜',
      '黃喉擬水龜',
      '巴西紅耳龜',
      '三線閉殼龜',
      '其他'
    ],
    'other': ['其他']
  };

  static const Map<String, String> breedKeyMap = {
    '道奇兔': 'dutch',
    '其他': 'other',
  };
}
