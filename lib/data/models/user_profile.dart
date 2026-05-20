class UserProfile {
  final int age;
  final int smokingYears;
  final double cigarettesPerDay;
  final String productType;
  final bool doesExercise;
  final bool morningCough;
  final bool shortnessOfBreath;
  final bool stressSmoker;
  final double pricePerCigarette;
  final String biologicalSex;
  final int heightCm;
  final int ageFirstCigarette;
  final int exerciseLevel;
  final int? selectedProductId;
  final int fagerstromScore;
  final int baselineCough;
  final int baselineBreathlessness;
  // Product data (populated from tobacco_products when available)
  final double? productPackPrice;
  final double? productNicotineMg;
  final double? productTarMg;

  const UserProfile({
    required this.age,
    required this.smokingYears,
    required this.cigarettesPerDay,
    required this.productType,
    this.doesExercise = false,
    this.morningCough = false,
    this.shortnessOfBreath = false,
    this.stressSmoker = false,
    this.pricePerCigarette = 0.30,
    this.biologicalSex = 'male',
    this.heightCm = 175,
    this.ageFirstCigarette = 16,
    this.exerciseLevel = 1,
    this.selectedProductId,
    this.fagerstromScore = 0,
    this.baselineCough = 1,
    this.baselineBreathlessness = 1,
    this.productPackPrice,
    this.productNicotineMg,
    this.productTarMg,
  });

  double get effectivePackPrice =>
      productPackPrice ?? (pricePerCigarette * 20);

  double get effectiveNicotineMg => productNicotineMg ?? 1.2;

  double get effectiveTarMg => productTarMg ?? 10.0;

  Map<String, dynamic> toJson() => {
        'age': age,
        'smokingYears': smokingYears,
        'cigarettesPerDay': cigarettesPerDay,
        'productType': productType,
        'doesExercise': doesExercise,
        'morningCough': morningCough,
        'shortnessOfBreath': shortnessOfBreath,
        'stressSmoker': stressSmoker,
        'pricePerCigarette': pricePerCigarette,
        'biologicalSex': biologicalSex,
        'heightCm': heightCm,
        'ageFirstCigarette': ageFirstCigarette,
        'exerciseLevel': exerciseLevel,
        'selectedProductId': selectedProductId,
        'fagerstromScore': fagerstromScore,
        'baselineCough': baselineCough,
        'baselineBreathlessness': baselineBreathlessness,
        'productPackPrice': productPackPrice,
        'productNicotineMg': productNicotineMg,
        'productTarMg': productTarMg,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] as int,
        smokingYears: json['smokingYears'] as int,
        cigarettesPerDay: (json['cigarettesPerDay'] as num).toDouble(),
        productType: json['productType'] as String,
        doesExercise: json['doesExercise'] as bool? ?? false,
        morningCough: json['morningCough'] as bool? ?? false,
        shortnessOfBreath: json['shortnessOfBreath'] as bool? ?? false,
        stressSmoker: json['stressSmoker'] as bool? ?? false,
        pricePerCigarette:
            (json['pricePerCigarette'] as num?)?.toDouble() ?? 0.30,
        biologicalSex: json['biologicalSex'] as String? ?? 'male',
        heightCm: json['heightCm'] as int? ?? 175,
        ageFirstCigarette: json['ageFirstCigarette'] as int? ?? 16,
        exerciseLevel: json['exerciseLevel'] as int? ?? 1,
        selectedProductId: json['selectedProductId'] as int?,
        fagerstromScore: json['fagerstromScore'] as int? ?? 0,
        baselineCough: json['baselineCough'] as int? ?? 1,
        baselineBreathlessness:
            json['baselineBreathlessness'] as int? ?? 1,
        productPackPrice: (json['productPackPrice'] as num?)?.toDouble(),
        productNicotineMg: (json['productNicotineMg'] as num?)?.toDouble(),
        productTarMg: (json['productTarMg'] as num?)?.toDouble(),
      );

  UserProfile copyWith({
    int? age,
    int? smokingYears,
    double? cigarettesPerDay,
    String? productType,
    bool? doesExercise,
    bool? morningCough,
    bool? shortnessOfBreath,
    bool? stressSmoker,
    double? pricePerCigarette,
    String? biologicalSex,
    int? heightCm,
    int? ageFirstCigarette,
    int? exerciseLevel,
    int? selectedProductId,
    int? fagerstromScore,
    int? baselineCough,
    int? baselineBreathlessness,
    double? productPackPrice,
    double? productNicotineMg,
    double? productTarMg,
  }) =>
      UserProfile(
        age: age ?? this.age,
        smokingYears: smokingYears ?? this.smokingYears,
        cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
        productType: productType ?? this.productType,
        doesExercise: doesExercise ?? this.doesExercise,
        morningCough: morningCough ?? this.morningCough,
        shortnessOfBreath: shortnessOfBreath ?? this.shortnessOfBreath,
        stressSmoker: stressSmoker ?? this.stressSmoker,
        pricePerCigarette: pricePerCigarette ?? this.pricePerCigarette,
        biologicalSex: biologicalSex ?? this.biologicalSex,
        heightCm: heightCm ?? this.heightCm,
        ageFirstCigarette: ageFirstCigarette ?? this.ageFirstCigarette,
        exerciseLevel: exerciseLevel ?? this.exerciseLevel,
        selectedProductId: selectedProductId ?? this.selectedProductId,
        fagerstromScore: fagerstromScore ?? this.fagerstromScore,
        baselineCough: baselineCough ?? this.baselineCough,
        baselineBreathlessness:
            baselineBreathlessness ?? this.baselineBreathlessness,
        productPackPrice: productPackPrice ?? this.productPackPrice,
        productNicotineMg: productNicotineMg ?? this.productNicotineMg,
        productTarMg: productTarMg ?? this.productTarMg,
      );
}
