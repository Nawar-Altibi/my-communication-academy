// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get academy => 'أكاديمية الاتصالات';

  @override
  String get headline => 'خطوتك التالية تبدأ بمهارة.';

  @override
  String get intro => 'تعلّم عملي للمهندسين الشغوفين بالمعرفة.';

  @override
  String get search => 'ابحث عن دورة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get all => 'الكل';

  @override
  String get telecom => 'الاتصالات';

  @override
  String get programming => 'البرمجة';

  @override
  String get ai => 'الذكاء الاصطناعي';

  @override
  String get data => 'البيانات';

  @override
  String get other => 'أخرى';

  @override
  String get beginner => 'مبتدئ';

  @override
  String get intermediate => 'متوسط';

  @override
  String get advanced => 'متقدم';

  @override
  String get unspecified => 'غير محدد';

  @override
  String get free => 'مجاني';

  @override
  String get priceUnavailable => 'السعر غير متاح';

  @override
  String get ratingUnavailable => 'التقييم غير متاح';

  @override
  String get durationUnavailable => 'المدة غير متاحة';

  @override
  String get catalogError => 'تعذّر تحميل الدورات';

  @override
  String get tryLater => 'يرجى المحاولة مجدداً بعد قليل.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get emptyTitle => 'لم نعثر على دورات';

  @override
  String get emptyMessage => 'جرّب بحثاً أو تصنيفاً آخر.';

  @override
  String get clearFilters => 'مسح البحث والفلاتر';

  @override
  String get refreshError => 'تعذّر التحديث. ما زالت الدورات السابقة ظاهرة.';

  @override
  String get details => 'تفاصيل الدورة';

  @override
  String get missingTitle => 'لم تعد هذه الدورة متاحة';

  @override
  String get missingMessage => 'قد تكون هذه الدورة قد أُزيلت من الأكاديمية.';

  @override
  String get detailError => 'تعذّر تحميل الدورة';

  @override
  String get temporaryMessage => 'حدثت مشكلة مؤقتة. يرجى المحاولة مجدداً.';

  @override
  String get instructorUnavailable => 'المدرّس غير متاح';

  @override
  String get descriptionUnavailable => 'لا يوجد وصف متاح.';

  @override
  String get lessons => 'دروس الدورة';

  @override
  String get emptyLessons => 'لا توجد دروس متاحة حالياً';

  @override
  String get checkBack => 'يرجى العودة لاحقاً.';

  @override
  String get preview => 'معاينة مجانية';

  @override
  String get available => 'متاح';

  @override
  String get locked => 'مقفل';

  @override
  String get lockedMessage => 'يجب الاشتراك في الدورة للوصول إلى هذا الدرس.';

  @override
  String get chooseTitle => 'مهارتك التالية بانتظارك';

  @override
  String get chooseMessage => 'اختر دورة لاستكشاف دروسها.';

  @override
  String get language => 'English';

  @override
  String get back => 'العودة إلى الدورات';

  @override
  String get loading => 'جارٍ تحميل الدورات';

  @override
  String courseCount(int count) {
    return '$count دورة';
  }

  @override
  String minuteCount(int count) {
    return '$count دقيقة';
  }

  @override
  String secondCount(int minutes, int seconds) {
    return '$minutes دقيقة و$seconds ثانية';
  }

  @override
  String lessonNumber(int number) {
    return 'الدرس $number';
  }

  @override
  String playing(String title) {
    return 'جارٍ التشغيل: $title';
  }

  @override
  String totalDuration(String duration) {
    return 'المدة الإجمالية: $duration';
  }

  @override
  String partialDuration(String duration, int count) {
    return '$duration معروفة · عدد الدروس ذات المدة غير المتاحة: $count';
  }

  @override
  String savedCatalog(String time) {
    return 'دورات محفوظة · $time';
  }

  @override
  String openCourse(String title) {
    return 'فتح الدورة: $title';
  }
}
