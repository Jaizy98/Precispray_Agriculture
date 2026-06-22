import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'firebase_options.dart';
import 'screens/weather_screen.dart';
import 'screens/map_screen.dart';
import 'screens/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ============================================================
// THEME — colors lifted straight from the AgriPulse prototype
// ============================================================
class AppColors {
  static const Color forest = Color(0xFF0B3D2E);
  static const Color forestDeep = Color(0xFF06241A);
  static const Color sprout = Color(0xFFE8F4D9);
  static const Color orange = Color(0xFFFF8C42);
  static const Color green = Color(0xFF4ADE80);
  static const Color cyan = Color(0xFF2DD4FF);
  static const Color yellow = Color(0xFFFFD23F);
  static const Color glass = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color textBody = Color(0xFFCDEBD8);
  static const Color textMuted = Color(0xFFA9D9C2);
  static const Color textFooter = Color(0xFF6F9C85);
}

TextStyle headingFont({double size = 28, FontWeight weight = FontWeight.w700, Color color = Colors.white}) {
  return GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color, height: 1.1);
}

TextStyle bodyFont({double size = 14, FontWeight weight = FontWeight.w500, Color color = AppColors.textBody}) {
  return GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color);
}

TextStyle monoFont({double size = 24, FontWeight weight = FontWeight.w600, Color color = AppColors.yellow}) {
  return GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);
}

// ============================================================
// LANGUAGE SYSTEM
// ------------------------------------------------------------
// One central string table keyed by [language code][string key].
// Only 'en' is filled in for now (per your instruction). The other
// four language codes exist and fall back to English automatically
// — so the dropdown is fully functional today, and translating later
// is just filling in the blank maps below, nothing else changes.
// ============================================================
class AppStrings {
  static const Map<String, Map<String, String>> _table = {
    'en': {
      'eyebrow': 'PRECISPRAY',
      'hero_title': 'Intelligence,\ncultivated.',
      'hero_subtitle': 'Precision in every plot — Sustainable, Safe and Economic.',
      'mission_tag': 'OUR MISSION',
      'mission_title': 'Built around the field,\nnot the office.',
      'mission1_title': 'Sustainability',
      'mission1_body': 'Minimizes chemical waste and soil contamination using optimized, solar-powered spraying.',
      'mission2_title': "Farmer's Health",
      'mission2_body': 'Protects farmers from various chronic diseases caused by pesticide drift and blowback.',
      'mission3_title': 'Economics and Agriculture',
      'mission3_body': 'Reduces costs and improves crop yield through efficient, drift-free spraying.',
      'features_tag': 'FEATURES',
      'features_title': 'Data driven,\nearth-grown.',
      'feature1_title': 'Live field mapping dashboard',
      'feature1_body': 'Displays and saves spray route on map in application.',
      'feature2_title': 'Weather based spray planner',
      'feature2_body': 'Identifies safe spraying window on the basis of regional weather forecast.',
      'feature3_title': 'Chemical Calculator',
      'feature3_body': 'Know your pesticide savings and money saved before you even start spraying.',
      'feature4_title': 'Spray report',
      'feature4_body': 'Prepares a full-fledged report of the spray session.',
      'about_tag': 'ABOUT US',
      'about_title': 'Built with you,\nfor the field.',
      'about_body': 'PreciSpray was founded to make precision farming accessible and practical. We replace guesswork with data, providing real-time soil and weather insights through an intuitive, farmer-first interface. Our mission is to optimize resource usage and help farmers grow with confidence—one acre at a time.',
      'footer': 'PreciSpray · scroll, hover and tap to explore',
      'drawer_irrigation': 'Irrigation control',
      'drawer_soil': 'Soil health',
      'drawer_weather': 'Weather alerts',
      'drawer_market': 'Market prices',
      'profile_name': 'Ramesh Sharma',
      'profile_sub': 'Nashik · 4.2 acres · Grapes',
      'drawer_profile': 'Profile',
      'drawer_chem_calc': 'Chemical calculator',
      'drawer_fav_weather': 'Favourable weather',
      'drawer_field_mapping': 'Field Mapping',
      'drawer_spray_report': 'Spray report',
      'drawer_savings_tracker': 'Savings tracker',
      'profile_screen_title': 'Your Profile',
      'profile_field_name': 'Name',
      'profile_field_age': 'Age',
      'profile_field_crops': 'Crops grown',
      'profile_plots_title': 'Plots',
      'profile_plot_area_hint': 'Area (in acres)',
      'profile_submit': 'Submit',
    },
    'hi': {
      'eyebrow': 'प्रेसिस्प्रे',
      'hero_title': 'बुद्धिमत्ता,\nखेत में उगाई गई।',
      'hero_subtitle': 'हर खेत में सटीकता — टिकाऊ, सुरक्षित और किफायती।',
      'mission_tag': 'हमारा उद्देश्य',
      'mission_title': 'खेत के लिए बनाया गया,\nदफ़्तर के लिए नहीं।',
      'mission1_title': 'टिकाऊपन',
      'mission1_body': 'सौर ऊर्जा से चलने वाले अनुकूलित छिड़काव से रासायनिक अपव्यय और मिट्टी के संदूषण को कम करता है।',
      'mission2_title': 'किसान का स्वास्थ्य',
      'mission2_body': 'कीटनाशक के बहाव और वापसी से होने वाली विभिन्न पुरानी बीमारियों से किसानों की रक्षा करता है।',
      'mission3_title': 'अर्थशास्त्र और कृषि',
      'mission3_body': 'कुशल, बहाव-मुक्त छिड़काव के माध्यम से लागत कम करता है और फसल की पैदावार बढ़ाता है।',
      'features_tag': 'विशेषताएं',
      'features_title': 'डेटा-आधारित,\nधरती से उगाया गया।',
      'feature1_title': 'लाइव फील्ड मैपिंग डैशबोर्ड',
      'feature1_body': 'एप्लिकेशन में मानचित्र पर छिड़काव मार्ग दिखाता और सहेजता है।',
      'feature2_title': 'मौसम आधारित छिड़काव योजक',
      'feature2_body': 'क्षेत्रीय मौसम पूर्वानुमान के आधार पर सुरक्षित छिड़काव का समय बताता है।',
      'feature3_title': 'रासायनिक मिश्रण कैलकुलेटर',
      'feature3_body': 'आवश्यकता के अनुसार किसानों को मिश्रण अनुपात की मात्रा बताता है।',
      'feature4_title': 'छिड़काव रिपोर्ट',
      'feature4_body': 'छिड़काव सत्र की पूरी रिपोर्ट तैयार करता है।',
      'about_tag': 'हमारे बारे में',
      'about_title': 'आपके साथ बनाया गया,\nखेत के लिए।',
      'about_body': 'प्रेसिस्प्रे की स्थापना सटीक खेती को सुलभ और व्यावहारिक बनाने के लिए की गई थी। हम अनुमान को डेटा से बदलते हैं, एक सहज, किसान-केंद्रित इंटरफ़ेस के माध्यम से वास्तविक समय में मिट्टी और मौसम की जानकारी प्रदान करते हैं। हमारा लक्ष्य संसाधनों के उपयोग को अनुकूलित करना और किसानों को एक-एक एकड़ में आत्मविश्वास के साथ आगे बढ़ने में मदद करना है।',
      'footer': 'प्रेसिस्प्रे · स्क्रॉल करें, स्पर्श करें और जानें',
      'drawer_irrigation': 'सिंचाई नियंत्रण',
      'drawer_soil': 'मिट्टी का स्वास्थ्य',
      'drawer_weather': 'मौसम चेतावनी',
      'drawer_market': 'बाज़ार भाव',
      'profile_name': 'रमेश शर्मा',
      'profile_sub': 'नासिक · 4.2 एकड़ · अंगूर',
    },
    'ta': {
      'eyebrow': 'பிரெசிஸ்ப்ரே',
      'hero_title': 'நுண்ணறிவு,\nவயலில் வளர்ந்தது.',
      'hero_subtitle': 'ஒவ்வொரு நிலத்திலும் துல்லியம் — நிலையான, பாதுகாப்பான மற்றும் சிக்கனமான.',
      'mission_tag': 'எங்கள் நோக்கம்',
      'mission_title': 'வயலை மையமாகக் கொண்டது,\nஅலுவலகத்தை அல்ல.',
      'mission1_title': 'நிலைத்தன்மை',
      'mission1_body': 'சூரிய சக்தியால் இயங்கும் உகந்த தெளிப்பு மூலம் இரசாயன கழிவு மற்றும் மண் மாசுபாட்டை குறைக்கிறது.',
      'mission2_title': 'விவசாயியின் ஆரோக்கியம்',
      'mission2_body': 'பூச்சிக்கொல்லி பறப்பு மற்றும் திரும்புதலால் ஏற்படும் பல்வேறு நாள்பட்ட நோய்களிலிருந்து விவசாயிகளை பாதுகாக்கிறது.',
      'mission3_title': 'பொருளாதாரம் மற்றும் வேளாண்மை',
      'mission3_body': 'திறமையான, பறப்பு-இல்லா தெளிப்பு மூலம் செலவைக் குறைத்து மகசூலை மேம்படுத்துகிறது.',
      'features_tag': 'அம்சங்கள்',
      'features_title': 'தரவு சார்ந்தது,\nநிலத்தில் வளர்ந்தது.',
      'feature1_title': 'நேரடி வயல் வரைபட டாஷ்போர்டு',
      'feature1_body': 'பயன்பாட்டில் வரைபடத்தில் தெளிப்பு பாதையை காட்டி சேமிக்கிறது.',
      'feature2_title': 'வானிலை அடிப்படையிலான தெளிப்பு திட்டமிடுபவர்',
      'feature2_body': 'பிராந்திய வானிலை முன்னறிவிப்பின் அடிப்படையில் பாதுகாப்பான தெளிப்பு நேரத்தை அடையாளம் காட்டுகிறது.',
      'feature3_title': 'இரசாயன கலவை கால்குலேட்டர்',
      'feature3_body': 'தேவைக்கேற்ப விவசாயிகளுக்கு கலவை விகித அளவை வழங்குகிறது.',
      'feature4_title': 'தெளிப்பு அறிக்கை',
      'feature4_body': 'தெளிப்பு அமர்வின் முழுமையான அறிக்கையை தயாரிக்கிறது.',
      'about_tag': 'எங்களைப் பற்றி',
      'about_title': 'உங்களுடன் உருவாக்கப்பட்டது,\nவயலுக்காக.',
      'about_body': 'துல்லியமான விவசாயத்தை அணுகக்கூடியதாகவும் நடைமுறைக்குரியதாகவும் மாற்ற பிரெசிஸ்ப்ரே நிறுவப்பட்டது. ஊகங்களை தரவுகளுடன் மாற்றி, உள்ளுணர்வுள்ள, விவசாயி-முதன்மையான இடைமுகம் மூலம் நிகழ்நேர மண் மற்றும் வானிலை தகவல்களை வழங்குகிறோம். வளங்களின் பயன்பாட்டை மேம்படுத்தி, ஒரு ஏக்கர் ஒரு நேரத்தில் விவசாயிகள் நம்பிக்கையுடன் வளர உதவுவதே எங்கள் நோக்கம்.',
      'footer': 'பிரெசிஸ்ப்ரே · உருட்டவும், தொடவும், ஆராயவும்',
      'drawer_irrigation': 'நீர்ப்பாசன கட்டுப்பாடு',
      'drawer_soil': 'மண் ஆரோக்கியம்',
      'drawer_weather': 'வானிலை எச்சரிக்கைகள்',
      'drawer_market': 'சந்தை விலைகள்',
      'profile_name': 'ரமேஷ் சர்மா',
      'profile_sub': 'நாசிக் · 4.2 ஏக்கர் · திராட்சை',
    },
    'bn': {
      'eyebrow': 'প্রেসিস্প্রে',
      'hero_title': 'বুদ্ধিমত্তা,\nক্ষেতে চাষ করা।',
      'hero_subtitle': 'প্রতিটি জমিতে নির্ভুলতা — টিকসই, নিরাপদ এবং সাশ্রয়ী।',
      'mission_tag': 'আমাদের লক্ষ্য',
      'mission_title': 'মাঠকে ঘিরে তৈরি,\nঅফিস নয়।',
      'mission1_title': 'টিকাউত্ব',
      'mission1_body': 'সৌরশক্তি চালিত অপ্টিমাইজড স্প্রে ব্যবহার করে রাসায়নিক অপচয় এবং মাটি দূষণ কমায়।',
      'mission2_title': 'কৃষকের স্বাস্থ্য',
      'mission2_body': 'কীটনাশকের প্রবাহ ও ব্লোব্যাক থেকে সৃষ্ট বিভিন্ন দীর্ঘস্থায়ী রোগ থেকে কৃষকদের রক্ষা করে।',
      'mission3_title': 'অর্থনীতি ও কৃষি',
      'mission3_body': 'দক্ষ, প্রবাহমুক্ত স্প্রে-এর মাধ্যমে খরচ কমায় এবং ফসলের ফলন বাড়ায়।',
      'features_tag': 'বৈশিষ্ট্য',
      'features_title': 'তথ্য-চালিত,\nমাটিতে উত্থিত।',
      'feature1_title': 'লাইভ ফিল্ড ম্যাপিং ড্যাশবোর্ড',
      'feature1_body': 'অ্যাপ্লিকেশনে মানচিত্রে স্প্রে রুট প্রদর্শন ও সংরক্ষণ করে।',
      'feature2_title': 'আবহাওয়া ভিত্তিক স্প্রে পরিকল্পক',
      'feature2_body': 'আঞ্চলিক আবহাওয়ার পূর্বাভাসের ভিত্তিতে নিরাপদ স্প্রে করার সময় চিহ্নিত করে।',
      'feature3_title': 'রাসায়নিক মিশ্রণ ক্যালকুলেটর',
      'feature3_body': 'প্রয়োজন অনুযায়ী কৃষকদের মিশ্রণ অনুপাতের পরিমাণ প্রদান করে।',
      'feature4_title': 'স্প্রে রিপোর্ট',
      'feature4_body': 'স্প্রে সেশনের একটি সম্পূর্ণ রিপোর্ট তৈরি করে।',
      'about_tag': 'আমাদের সম্পর্কে',
      'about_title': 'আপনার সাথে তৈরি,\nমাঠের জন্য।',
      'about_body': 'প্রেসিস্প্রে নির্ভুল কৃষিকে সহজলভ্য ও ব্যবহারিক করার জন্য প্রতিষ্ঠিত হয়েছিল। আমরা অনুমানকে তথ্য দিয়ে প্রতিস্থাপন করি, একটি স্বজ্ঞাত, কৃষক-প্রথম ইন্টারফেসের মাধ্যমে রিয়েল-টাইম মাটি এবং আবহাওয়ার তথ্য প্রদান করি। আমাদের লক্ষ্য সম্পদ ব্যবহার অপ্টিমাইজ করা এবং কৃষকদের এক একর সময়ে আত্মবিশ্বাসের সাথে বেড়ে উঠতে সাহায্য করা।',
      'footer': 'প্রেসিস্প্রে · স্ক্রল, স্পর্শ এবং ট্যাপ করে অন্বেষণ করুন',
      'drawer_irrigation': 'সেচ নিয়ন্ত্রণ',
      'drawer_soil': 'মাটির স্বাস্থ্য',
      'drawer_weather': 'আবহাওয়া সতর্কতা',
      'drawer_market': 'বাজার দর',
      'profile_name': 'রমেশ শর্মা',
      'profile_sub': 'নাসিক · ৪.২ একর · আঙুর',
    },
    'mr': {
      'eyebrow': 'प्रेसिस्प्रे',
      'hero_title': 'बुद्धिमत्ता,\nशेतात जोपासलेली.',
      'hero_subtitle': 'प्रत्येक शेतात अचूकता — टिकाऊ, सुरक्षित आणि किफायतशीर.',
      'mission_tag': 'आमचे उद्दिष्ट',
      'mission_title': 'शेतासाठी तयार केलेले,\nऑफिससाठी नाही.',
      'mission1_title': 'टिकाऊपणा',
      'mission1_body': 'सौरऊर्जेवर चालणाऱ्या ऑप्टिमाइझ्ड फवारणीद्वारे रासायनिक अपव्यय आणि मातीचे प्रदूषण कमी करते.',
      'mission2_title': "शेतकऱ्याचे आरोग्य",
      'mission2_body': 'कीटकनाशकांच्या प्रवाहामुळे आणि परत येण्यामुळे होणाऱ्या विविध दीर्घकालीन आजारांपासून शेतकऱ्यांचे संरक्षण करते.',
      'mission3_title': 'अर्थशास्त्र आणि शेती',
      'mission3_body': 'कार्यक्षम, प्रवाहमुक्त फवारणीद्वारे खर्च कमी करते आणि पीक उत्पादन सुधारते.',
      'features_tag': 'वैशिष्ट्ये',
      'features_title': 'डेटा-आधारित,\nमातीतून उगवलेले.',
      'feature1_title': 'थेट क्षेत्र मॅपिंग डॅशबोर्ड',
      'feature1_body': 'अॅप्लिकेशनमध्ये नकाशावर फवारणी मार्ग दाखवते आणि जतन करते.',
      'feature2_title': 'हवामान आधारित फवारणी नियोजक',
      'feature2_body': 'प्रादेशिक हवामान अंदाजाच्या आधारे सुरक्षित फवारणीची वेळ ओळखते.',
      'feature3_title': 'रासायनिक मिश्रण कॅल्क्युलेटर',
      'feature3_body': 'आवश्यकतेनुसार शेतकऱ्यांना मिश्रण प्रमाणाचे मार्गदर्शन करते.',
      'feature4_title': 'फवारणी अहवाल',
      'feature4_body': 'फवारणी सत्राचा संपूर्ण अहवाल तयार करते.',
      'about_tag': 'आमच्याबद्दल',
      'about_title': 'तुमच्यासोबत तयार केलेले,\nशेतासाठी.',
      'about_body': 'प्रेसिस्प्रेची स्थापना अचूक शेती सुलभ आणि व्यावहारिक बनवण्यासाठी झाली. आम्ही अंदाजाची जागा डेटाने घेतो, एका सहज, शेतकरी-केंद्रित इंटरफेसद्वारे रिअल-टाइम माती आणि हवामान माहिती पुरवतो. संसाधनांचा वापर अनुकूल करणे आणि शेतकऱ्यांना एक एकर वेळी आत्मविश्वासाने वाढण्यास मदत करणे हे आमचे ध्येय आहे.',
      'footer': 'प्रेसिस्प्रे · स्क्रोल करा, स्पर्श करा आणि एक्सप्लोर करा',
      'drawer_irrigation': 'सिंचन नियंत्रण',
      'drawer_soil': 'मातीचे आरोग्य',
      'drawer_weather': 'हवामान सूचना',
      'drawer_market': 'बाजारभाव',
      'profile_name': 'रमेश शर्मा',
      'profile_sub': 'नाशिक · ४.२ एकर · द्राक्षे',
    },
  };

  static String t(String langCode, String key) {
    return _table[langCode]?[key] ?? _table['en']![key] ?? key;
  }
}

class LanguageController extends ChangeNotifier {
  String _code = 'en';
  String get code => _code;

  void setLanguage(String code) {
    if (_code == code) return;
    _code = code;
    notifyListeners();
  }

  String t(String key) => AppStrings.t(_code, key);
}

class LanguageScope extends InheritedNotifier<LanguageController> {
  const LanguageScope({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(scope != null, 'No LanguageScope found in context');
    return scope!.notifier!;
  }
}

const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ta': 'தமிழ்',
  'bn': 'বাংলা',
  'mr': 'मराठी',
};

// ============================================================
// 1. LOGIN PAGE (unchanged)
// ============================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleAuth(BuildContext context) async {
    setState(() => _loading = true);
    String email = "${_phoneController.text.trim()}@precispray.com";
    String password = _passwordController.text.trim();
    try {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } catch (_) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnimationScreen()),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/login_bg.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Contact Number",
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              ),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _handleAuth(context),
                      child: const Text("Login / Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 2. ANIMATION / TRANSITION SCREEN (unchanged)
// ============================================================
class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});
  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/animation.mp4');
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    }).catchError((error) {
      debugPrint('Video failed to initialize: $error');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
    _controller.addListener(_checkVideoEnd);
  }

  void _checkVideoEnd() {
    if (_navigated) return;
    final value = _controller.value;
    if (value.isInitialized && value.position >= value.duration && !value.isPlaying) {
      _navigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Image.asset('assets/top_image.png', fit: BoxFit.cover)),
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
            Expanded(child: Image.asset('assets/bottom_image.png', fit: BoxFit.cover)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3. DASHBOARD SCREEN — PreciSpray content
// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _drawerOpen = false;
  late final LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      controller: _languageController,
      child: Scaffold(
        backgroundColor: AppColors.forestDeep,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -1.0),
                  radius: 1.4,
                  colors: [Color(0xFF103D2C), Color(0xFF07261C), Color(0xFF051A13)],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            const _GlowBlob(top: -120, right: -100, size: 420, color: AppColors.cyan, opacity: 0.30),
            const _GlowBlob(bottom: 80, left: -140, size: 380, color: AppColors.orange, opacity: 0.30),
            const _GlowBlob(top: 320, right: 30, size: 300, color: AppColors.yellow, opacity: 0.15),

            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HeroSlider()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 60, 22, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _SectionHead(tagKey: 'mission_tag', titleKey: 'mission_title'),
                      const SizedBox(height: 18),
                      _ScrollReveal(
                        index: 0,
                        child: _MissionCard(
                          iconPainter: const _SustainabilityIconPainter(),
                          glow: AppColors.green,
                          titleKey: 'mission1_title',
                          bodyKey: 'mission1_body',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ScrollReveal(
                        index: 1,
                        child: _MissionCard(
                          iconPainter: const _HealthIconPainter(),
                          glow: AppColors.cyan,
                          titleKey: 'mission2_title',
                          bodyKey: 'mission2_body',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ScrollReveal(
                        index: 2,
                        child: _MissionCard(
                          iconPainter: const _EconomicsIconPainter(),
                          glow: AppColors.yellow,
                          titleKey: 'mission3_title',
                          bodyKey: 'mission3_body',
                        ),
                      ),
                      const SizedBox(height: 70),
                      const _SectionHead(tagKey: 'features_tag', titleKey: 'features_title'),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.82,
                        children: [
                          _ScrollReveal(
                            index: 0,
                            child: const _FeatureCard(
                              icon: Icons.map_outlined,
                              color: AppColors.cyan,
                              titleKey: 'feature1_title',
                              bodyKey: 'feature1_body',
                            ),
                          ),
                          _ScrollReveal(
                            index: 1,
                            child: const _FeatureCard(
                              icon: Icons.cloud_queue,
                              color: AppColors.orange,
                              titleKey: 'feature2_title',
                              bodyKey: 'feature2_body',
                            ),
                          ),
                          _ScrollReveal(
                            index: 2,
                            child: const _FeatureCard(
                              icon: Icons.science_outlined,
                              color: AppColors.yellow,
                              titleKey: 'feature3_title',
                              bodyKey: 'feature3_body',
                            ),
                          ),
                          _ScrollReveal(
                            index: 3,
                            child: const _FeatureCard(
                              icon: Icons.summarize_outlined,
                              color: AppColors.green,
                              titleKey: 'feature4_title',
                              bodyKey: 'feature4_body',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 70),
                      const _SectionHead(tagKey: 'about_tag', titleKey: 'about_title'),
                      const SizedBox(height: 18),
                      const _ScrollReveal(index: 0, child: _AboutBox()),
                      const SizedBox(height: 30),
                      Center(
                        child: _TranslatedText(
                          'footer',
                          style: (t) => bodyFont(size: 12, color: AppColors.textFooter),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ]),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _GlassTopBar(
                isOpen: _drawerOpen,
                onMenuTap: () => setState(() => _drawerOpen = !_drawerOpen),
              ),
            ),

            if (_drawerOpen)
              GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            _SideDrawer(isOpen: _drawerOpen, onClose: () => setState(() => _drawerOpen = false)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Small helper: a Text widget that re-reads its string from
// LanguageScope every time the language changes.
// ----------------------------------------------------------
class _TranslatedText extends StatelessWidget {
  final String stringKey;
  final TextStyle Function(String translated) style;
  final TextAlign? textAlign;
  const _TranslatedText(this.stringKey, {required this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    final translated = lang.t(stringKey);
    return Text(translated, style: style(translated), textAlign: textAlign);
  }
}

// ----------------------------------------------------------
// Ambient glow blob
// ----------------------------------------------------------
class _GlowBlob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double opacity;
  const _GlowBlob({this.top, this.bottom, this.left, this.right, required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
            boxShadow: [BoxShadow(color: color.withOpacity(opacity), blurRadius: 80, spreadRadius: 40)],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Glass top bar — language dropdown now actually switches
// the app's LanguageController instead of just local state.
// ----------------------------------------------------------
class _GlassTopBar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onMenuTap;

  const _GlassTopBar({
    required this.isOpen,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xD9061C14), Color(0x00061C14)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isOpen ? AppColors.cyan : AppColors.glassBorder),
                  ),
                  child: Icon(isOpen ? Icons.close : Icons.menu, color: Colors.white, size: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan),
                      alignment: Alignment.center,
                      child: const Text('A', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.forestDeep)),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: lang.code,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.forest,
                      iconEnabledColor: Colors.white,
                      style: bodyFont(size: 14, weight: FontWeight.w600, color: Colors.white),
                      items: kSupportedLanguages.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (code) {
                        if (code != null) lang.setLanguage(code);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Side drawer with profile + feature shortcuts
// ----------------------------------------------------------
class _SideDrawer extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  const _SideDrawer({required this.isOpen, required this.onClose});

  @override
  State<_SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<_SideDrawer> {
  @override
  void initState() {
    super.initState();
    ProfileStore().addListener(_onProfileChange);
  }

  void _onProfileChange() => setState(() {});

  @override
  void dispose() {
    ProfileStore().removeListener(_onProfileChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      left: widget.isOpen ? 0 : -300,
      width: 300,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.forest.withOpacity(0.92), AppColors.forestDeep.withOpacity(0.97)],
            ),
            border: const Border(right: BorderSide(color: AppColors.glassBorder)),
            boxShadow: widget.isOpen ? [const BoxShadow(color: Colors.black54, blurRadius: 60, offset: Offset(30, 0))] : [],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 70, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── profile summary ──────────────────────
                  if (profile.hasProfile) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.green.withOpacity(0.5)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                              style: headingFont(size: 18, color: AppColors.green),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profile.name,
                                    style: bodyFont(size: 14, weight: FontWeight.w700, color: Colors.white),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (profile.crops.isNotEmpty)
                                  Text(profile.crops,
                                      style: bodyFont(size: 12, color: AppColors.textMuted),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (profile.plotNames.isNotEmpty || profile.plotAreas.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      List.generate(
                                        profile.plotAreas.length,
                                        (i) {
                                          final n = i < profile.plotNames.length && profile.plotNames[i].trim().isNotEmpty
                                              ? profile.plotNames[i].trim()
                                              : 'Plot ${i + 1}';
                                          final a = profile.plotAreas[i].trim();
                                          return a.isNotEmpty ? '$n · ${a} ac' : n;
                                        },
                                      ).join('  |  '),
                                      style: bodyFont(size: 11, color: AppColors.green),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(color: AppColors.glassBorder, height: 1),
                  const SizedBox(height: 22),
                  _DrawerFeature(
                    icon: Icons.person,
                    color: AppColors.green,
                    labelKey: 'drawer_profile',
                    onTap: () {
                      widget.onClose();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _DrawerFeature(icon: Icons.science_outlined, color: AppColors.cyan, labelKey: 'drawer_chem_calc',
                    onTap: () {
                      widget.onClose();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen()));
                    },
                  ),
                  const SizedBox(height: 18),
                  _DrawerFeature(icon: Icons.wb_sunny_outlined, color: AppColors.yellow, labelKey: 'drawer_fav_weather',
                    onTap: () {
                      widget.onClose();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
                    },
                  ),
                  const SizedBox(height: 18),
                  _DrawerFeature(icon: Icons.map_outlined, color: AppColors.orange, labelKey: 'drawer_field_mapping',
                    onTap: () {
                      widget.onClose();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                    },
                  ),
                  const SizedBox(height: 18),
                  _DrawerFeature(icon: Icons.summarize_outlined, color: AppColors.green, labelKey: 'drawer_spray_report'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFeature extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String labelKey;
  final VoidCallback? onTap;
  const _DrawerFeature({required this.icon, required this.color, required this.labelKey, this.onTap});

  @override
  State<_DrawerFeature> createState() => _DrawerFeatureState();
}

class _DrawerFeatureState extends State<_DrawerFeature> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp: (_) => setState(() => _hover = false),
      onTapCancel: () => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hover ? AppColors.glass : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hover ? AppColors.glassBorder : Colors.transparent),
        ),
        transform: Matrix4.translationValues(_hover ? 4 : 0, 0, 0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _hover ? widget.color : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _hover ? [BoxShadow(color: widget.color, blurRadius: 18)] : [],
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 18, color: _hover ? AppColors.forestDeep : Colors.white),
            ),
            const SizedBox(width: 14),
            Text(lang.t(widget.labelKey), style: bodyFont(size: 14, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE SCREEN — reached from the drawer's "Profile" button.
// Background kept consistent with the dashboard (same gradient
// + glow blobs) so it doesn't feel like a different app.
// ============================================================
// PROFILE STORE — simple in-memory store for MVP.
// Holds the last submitted profile so the drawer can display it.
// ============================================================
class ProfileStore extends ChangeNotifier {
  static final ProfileStore _instance = ProfileStore._internal();
  factory ProfileStore() => _instance;
  ProfileStore._internal();

  String name   = '';
  String age    = '';
  String crops  = '';
  List<String> plotAreas = [];
  List<String> plotNames = [];

  bool get hasProfile => name.trim().isNotEmpty;

  void save({
    required String name,
    required String age,
    required String crops,
    required List<String> plotAreas,
    required List<String> plotNames,
  }) {
    this.name      = name.trim();
    this.age       = age.trim();
    this.crops     = crops.trim();
    this.plotAreas = plotAreas;
    this.plotNames = plotNames;
    notifyListeners();
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _PlotEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cropsController = TextEditingController();
  final List<_PlotEntry> _plots = [_PlotEntry()];

  @override
  void initState() {
    super.initState();
    // Pre-fill from store if a profile was already saved
    final store = ProfileStore();
    if (store.hasProfile) {
      _nameController.text  = store.name;
      _ageController.text   = store.age;
      _cropsController.text = store.crops;
      if (store.plotAreas.isNotEmpty) {
        _plots.clear();
        for (int i = 0; i < store.plotAreas.length; i++) {
          final entry = _PlotEntry();
          entry.nameController.text = i < store.plotNames.length ? store.plotNames[i] : '';
          entry.areaController.text = store.plotAreas[i];
          _plots.add(entry);
        }
      }
    }
  }

  void _addPlot() {
    setState(() => _plots.add(_PlotEntry()));
  }

  void _removePlot(int index) {
    if (_plots.length == 1) return; // always keep at least one plot tab
    setState(() {
      _plots[index].nameController.dispose();
      _plots[index].areaController.dispose();
      _plots.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }
    ProfileStore().save(
      name: _nameController.text,
      age: _ageController.text,
      crops: _cropsController.text,
      plotNames: _plots.map((p) => p.nameController.text).toList(),
      plotAreas: _plots.map((p) => p.areaController.text).toList(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cropsController.dispose();
    for (final plot in _plots) {
      plot.nameController.dispose();
      plot.areaController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDeep,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.6, -1.0),
                radius: 1.4,
                colors: [Color(0xFF103D2C), Color(0xFF07261C), Color(0xFF051A13)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          const _GlowBlob(top: -120, right: -100, size: 420, color: AppColors.cyan, opacity: 0.30),
          const _GlowBlob(bottom: 80, left: -140, size: 380, color: AppColors.orange, opacity: 0.30),
          const _GlowBlob(top: 320, right: 30, size: 300, color: AppColors.yellow, opacity: 0.15),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Your Profile', style: headingFont(size: 26)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  _ProfileLabel('Name'),
                  const SizedBox(height: 8),
                  _ProfileTextField(controller: _nameController, hint: 'Enter your name'),
                  const SizedBox(height: 20),

                  _ProfileLabel('Age'),
                  const SizedBox(height: 8),
                  _ProfileTextField(controller: _ageController, hint: 'Enter your age', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  _ProfileLabel('Crops grown'),
                  const SizedBox(height: 8),
                  _ProfileTextField(controller: _cropsController, hint: 'e.g. Grapes, Wheat'),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ProfileLabel('Plots'),
                      GestureDetector(
                        onTap: _addPlot,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.5), blurRadius: 16)],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.add, color: AppColors.forestDeep, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  ...List.generate(_plots.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlotTab(
                        index: i,
                        nameController: _plots[i].nameController,
                        areaController: _plots[i].areaController,
                        onRemove: _plots.length > 1 ? () => _removePlot(i) : null,
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _handleSubmit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.green, AppColors.cyan]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.35), blurRadius: 24)],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Submit',
                          style: bodyFont(size: 16, weight: FontWeight.w700, color: AppColors.forestDeep),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLabel extends StatelessWidget {
  final String text;
  const _ProfileLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: bodyFont(size: 14, weight: FontWeight.w700, color: AppColors.textMuted).copyWith(letterSpacing: 0.5));
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _ProfileTextField({required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: bodyFont(size: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: bodyFont(size: 15, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// One "tab" for a plot — its number/label plus an area input.
/// Tapping + above adds another one of these; each keeps its own
/// area value independently.
class _PlotTab extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController areaController;
  final VoidCallback? onRemove;
  const _PlotTab({
    required this.index,
    required this.nameController,
    required this.areaController,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x26FFFFFF), Color(0x14FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.orange.withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.grass, size: 18, color: AppColors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editable plot name
                TextField(
                  controller: nameController,
                  style: bodyFont(size: 14, weight: FontWeight.w700, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Plot ${index + 1} name',
                    hintStyle: bodyFont(size: 14, weight: FontWeight.w700, color: AppColors.textMuted),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 6),
                // Editable area
                TextField(
                  controller: areaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: bodyFont(size: 13, color: AppColors.textBody),
                  decoration: InputDecoration(
                    hintText: 'Area (in acres)',
                    hintStyle: bodyFont(size: 13, color: AppColors.textMuted),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Hero slider — farm1-4.jpg, auto-advance + manual swipe,
// continuous scale/opacity driven by live page position.
// BoxFit.contain so the full photo is always visible.
// ----------------------------------------------------------
class _HeroSlider extends StatefulWidget {
  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  static const List<String> _images = [
    'assets/farm1.jpg',
    'assets/farm2.jpg',
    'assets/farm3.jpg',
    'assets/farm4.jpg',
  ];

  late final PageController _pageController;
  Timer? _timer;
  int _index = 0;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3600), (_) {
      if (!mounted || _userInteracting) return;
      final next = (_index + 1) % _images.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 1300),
        curve: const Cubic(0.16, 1, 0.3, 1),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF103D2C), Color(0xFF06241A)],
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _userInteracting = true;
              } else if (notification is ScrollEndNotification) {
                _userInteracting = false;
                if (_pageController.page != null) {
                  _index = _pageController.page!.round();
                }
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double scale = 1.0;
                    double opacity = 1.0;
                    if (_pageController.position.haveDimensions) {
                      final page = _pageController.page ?? _index.toDouble();
                      final delta = (page - i);
                      scale = 1.0 - (delta.abs().clamp(0.0, 1.0) * 0.08);
                      opacity = 1.0 - (delta.abs().clamp(0.0, 1.0) * 0.55);
                    }
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          _images[i],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenHeight * 0.55,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00072618), Color(0xF2072618)],
                    stops: [0.0, 0.85],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('hero_title'), style: headingFont(size: 36)),
                const SizedBox(height: 10),
                SizedBox(
                  width: 320,
                  child: Text(
                    lang.t('hero_subtitle'),
                    style: bodyFont(size: 14, color: AppColors.textBody),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(_images.length, (i) {
                    final active = i == _index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.only(right: 8),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.orange : Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: active
                              ? [BoxShadow(color: AppColors.orange.withOpacity(0.6), blurRadius: 10)]
                              : [],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Reusable scroll-entry wrapper — fires once when ~18% visible.
// ----------------------------------------------------------
class _ScrollReveal extends StatefulWidget {
  final Widget child;
  final int index;
  const _ScrollReveal({required this.child, this.index = 0});

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> with SingleTickerProviderStateMixin {
  bool _triggered = false;
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _curve = CurvedAnimation(parent: _controller, curve: const Cubic(0.16, 1, 0.3, 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_triggered && info.visibleFraction > 0.18) {
      _triggered = true;
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reveal_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final t = _curve.value;
          return Opacity(
            opacity: t,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(0.0, 40 * (1 - t))
                ..rotateX(0.14 * (1 - t))
                ..scale(0.96 + (0.04 * t)),
              child: widget.child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ----------------------------------------------------------
// Section heading — tag label rendered bold + underlined,
// per your request (e.g. "OUR MISSION", "FEATURES", "ABOUT US").
// ----------------------------------------------------------
class _SectionHead extends StatelessWidget {
  final String tagKey;
  final String titleKey;
  const _SectionHead({required this.tagKey, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t(tagKey),
          style: bodyFont(size: 16, weight: FontWeight.w800, color: AppColors.green).copyWith(
            letterSpacing: 1.5,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.green,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(lang.t(titleKey), style: headingFont(size: 32)),
      ],
    );
  }
}

// ----------------------------------------------------------
// Mission card — tap to glow. Background opacity raised from
// the original ~7% white to ~15%/8% so the card reads less
// see-through against the busy gradient background.
// ----------------------------------------------------------
class _MissionCard extends StatefulWidget {
  final CustomPainter iconPainter;
  final Color glow;
  final String titleKey;
  final String bodyKey;
  const _MissionCard({required this.iconPainter, required this.glow, required this.titleKey, required this.bodyKey});

  @override
  State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _active = true),
      onTapUp: (_) => setState(() => _active = false),
      onTapCancel: () => setState(() => _active = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x26FFFFFF), Color(0x14FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: _active
              ? [BoxShadow(color: widget.glow.withOpacity(0.35), blurRadius: 40, spreadRadius: 2)]
              : [],
        ),
        transform: Matrix4.translationValues(0, _active ? -4 : 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _active ? widget.glow : Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _active ? [BoxShadow(color: widget.glow, blurRadius: 24)] : [],
              ),
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(_active ? -0.14 : 0),
              transformAlignment: Alignment.center,
              child: CustomPaint(
                size: const Size(26, 26),
                painter: widget.iconPainter,
              ),
            ),
            const SizedBox(height: 16),
            Text(lang.t(widget.titleKey), style: bodyFont(size: 17, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text(lang.t(widget.bodyKey), style: bodyFont(size: 13, color: AppColors.textBody).copyWith(height: 1.55)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// Custom-drawn mission icons — line art, color comes from the
// icon-box state so it flips white<->dark exactly like before.
// ----------------------------------------------------------

/// Sustainability — solar panel + sun, for the solar-powered
/// spraying detail in the mission copy.
class _SustainabilityIconPainter extends CustomPainter {
  const _SustainabilityIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;

    final panel = Path()
      ..moveTo(w * 0.08, h * 0.62)
      ..lineTo(w * 0.40, h * 0.40)
      ..lineTo(w * 0.92, h * 0.55)
      ..lineTo(w * 0.62, h * 0.80)
      ..close();
    canvas.drawPath(panel, paint);
    canvas.drawLine(Offset(w * 0.24, h * 0.50), Offset(w * 0.46, h * 0.70), paint);
    canvas.drawLine(Offset(w * 0.40, h * 0.40), Offset(w * 0.62, h * 0.80), paint);
    canvas.drawLine(Offset(w * 0.66, h * 0.47), Offset(w * 0.78, h * 0.74), paint);

    canvas.drawCircle(Offset(w * 0.62, h * 0.18), w * 0.09, paint);
    final rayOffsets = [
      [Offset(w * 0.62, h * 0.02), Offset(w * 0.62, h * 0.08)],
      [Offset(w * 0.50, h * 0.06), Offset(w * 0.55, h * 0.11)],
      [Offset(w * 0.74, h * 0.06), Offset(w * 0.69, h * 0.11)],
      [Offset(w * 0.46, h * 0.18), Offset(w * 0.52, h * 0.18)],
      [Offset(w * 0.78, h * 0.18), Offset(w * 0.72, h * 0.18)],
    ];
    for (final pair in rayOffsets) {
      canvas.drawLine(pair[0], pair[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Farmer's Health — shield with a cross, for protection from
/// pesticide drift and blowback.
class _HealthIconPainter extends CustomPainter {
  const _HealthIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width, h = size.height;

    final shield = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.86, h * 0.20)
      ..lineTo(w * 0.86, h * 0.52)
      ..cubicTo(w * 0.86, h * 0.78, w * 0.68, h * 0.92, w * 0.5, h * 0.96)
      ..cubicTo(w * 0.32, h * 0.92, w * 0.14, h * 0.78, w * 0.14, h * 0.52)
      ..lineTo(w * 0.14, h * 0.20)
      ..close();
    canvas.drawPath(shield, paint);

    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.5, h * 0.62), paint);
    canvas.drawLine(Offset(w * 0.37, h * 0.48), Offset(w * 0.63, h * 0.48), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Economics and Agriculture — leaf + rupee mark, for cost
/// savings and crop yield together.
class _EconomicsIconPainter extends CustomPainter {
  const _EconomicsIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width, h = size.height;

    final leaf = Path()
      ..moveTo(w * 0.10, h * 0.85)
      ..cubicTo(w * 0.05, h * 0.55, w * 0.18, h * 0.30, w * 0.42, h * 0.22)
      ..cubicTo(w * 0.40, h * 0.50, w * 0.30, h * 0.72, w * 0.10, h * 0.85)
      ..close();
    canvas.drawPath(leaf, paint);
    canvas.drawLine(Offset(w * 0.14, h * 0.78), Offset(w * 0.36, h * 0.32), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '₹',
        style: TextStyle(color: Colors.white, fontSize: h * 0.62, fontWeight: FontWeight.w700, height: 1.0),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.50, h * 0.16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------
// Feature card — 2x2 grid, tap to glow. Background opacity
// raised the same way as mission cards.
// ----------------------------------------------------------
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String titleKey;
  final String bodyKey;
  const _FeatureCard({required this.icon, required this.color, required this.titleKey, required this.bodyKey});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _active = true),
      onTapUp: (_) => setState(() => _active = false),
      onTapCancel: () => setState(() => _active = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          color: _active ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.11),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _active ? widget.color : AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _active ? widget.color : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
                boxShadow: _active ? [BoxShadow(color: widget.color, blurRadius: 22)] : [],
              ),
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(_active ? 0.1 : 0)..scale(_active ? 1.1 : 1.0),
              transformAlignment: Alignment.center,
              child: Icon(widget.icon, size: 20, color: _active ? AppColors.forestDeep : Colors.white),
            ),
            const SizedBox(height: 14),
            Text(lang.t(widget.titleKey), style: bodyFont(size: 14, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(lang.t(widget.bodyKey), style: bodyFont(size: 11.5, color: AppColors.textMuted).copyWith(height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// About box — content fully replaced with PreciSpray copy.
// Background opacity raised the same way as the other cards.
// ----------------------------------------------------------
class _AboutBox extends StatelessWidget {
  const _AboutBox();

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x24FFFFFF), Color(0x12FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        lang.t('about_body'),
        style: bodyFont(size: 14, color: AppColors.textBody).copyWith(height: 1.7),
      ),
    );
  }
}
