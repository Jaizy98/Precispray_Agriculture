import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';

// ── Re-use B's design tokens ──────────────────────────────
class _C {
  static const forest     = Color(0xFF0B3D2E);
  static const forestDeep = Color(0xFF06241A);
  static const orange     = Color(0xFFFF8C42);
  static const green      = Color(0xFF4ADE80);
  static const cyan       = Color(0xFF2DD4FF);
  static const yellow     = Color(0xFFFFD23F);
  static const glass      = Color(0x0FFFFFFF);
  static const glassBorder= Color(0x1FFFFFFF);
  static const textBody   = Color(0xFFCDEBD8);
  static const textMuted  = Color(0xFFA9D9C2);
}

TextStyle _heading({double size = 22, Color color = Colors.white}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w700, color: color, height: 1.1);

TextStyle _body({double size = 14, Color color = _C.textBody}) =>
    GoogleFonts.manrope(fontSize: size, fontWeight: FontWeight.w500, color: color);

TextStyle _mono({double size = 28, Color color = _C.yellow}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: FontWeight.w600, color: color);

// ─────────────────────────────────────────────────────────

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String locationName = "Detecting location…";
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _getLocationName(double lat, double lon) async {
    try {
      final url =
          "https://geocoding-api.open-meteo.com/v1/reverse"
          "?latitude=$lat&longitude=$lon&language=en";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          locationName =
              "${data['city'] ?? data['locality'] ?? 'Unknown'}, "
              "${data['principalSubdivision'] ?? ''}";
        });
      }
    } catch (_) {}
  }

  Future<void> _loadWeather() async {
    setState(() { isLoading = true; errorMsg = null; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      await _getLocationName(pos.latitude, pos.longitude);
      final data = await _weatherService.getWeather(pos.latitude, pos.longitude);
      setState(() { weatherData = data; isLoading = false; });
    } catch (e) {
      setState(() { errorMsg = e.toString(); isLoading = false; });
    }
  }

  // ── scaffold background (matches DashboardScreen) ────────
  BoxDecoration get _bg => const BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.6, -1.0),
      radius: 1.4,
      colors: [Color(0xFF103D2C), Color(0xFF07261C), Color(0xFF051A13)],
      stops: [0.0, 0.45, 1.0],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.forestDeep,
      body: Stack(
        children: [
          Container(decoration: _bg),
          // ambient glow blobs
          _blob(top: -80, right: -80, size: 320, color: _C.cyan, opacity: 0.25),
          _blob(bottom: 60, left: -100, size: 300, color: _C.orange, opacity: 0.25),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: _C.cyan))
                      : errorMsg != null
                          ? _errorView()
                          : _content(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _C.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.glassBorder),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Weather", style: _heading(size: 24)),
              Text(locationName, style: _body(size: 12, color: _C.textMuted)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loadWeather,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _C.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.glassBorder),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, color: _C.textMuted, size: 48),
        const SizedBox(height: 16),
        Text("Could not load weather", style: _heading(size: 18)),
        const SizedBox(height: 8),
        Text(errorMsg ?? "", style: _body(size: 13, color: _C.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _pillButton("Retry", _loadWeather),
      ]),
    ),
  );

  Widget _content() {
    final cur = weatherData!['current'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Current weather card
        _glassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Current Weather", style: _body(size: 13, color: _C.textMuted).copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Text("${cur['temperature_2m']}°C", style: _mono(size: 52)),
            const SizedBox(height: 16),
            Row(children: [
              _statChip(Icons.water_drop_outlined, "${cur['relative_humidity_2m']}%", _C.cyan),
              const SizedBox(width: 12),
              _statChip(Icons.air, "${cur['wind_speed_10m']} km/h", _C.orange),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        Text("Hourly Forecast", style: _heading(size: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (_, i) => _hourlyCard(i),
          ),
        ),
        const SizedBox(height: 24),
        Text("7-Day Forecast", style: _heading(size: 18)),
        const SizedBox(height: 12),
        _glassCard(
          child: Column(children: List.generate(7, (i) => _dailyRow(i))),
        ),
      ]),
    );
  }

  Widget _hourlyCard(int i) {
    final hourly = weatherData!['hourly'];
    final time = DateFormat('h a').format(DateTime.parse(hourly['time'][i]));
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.glass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.glassBorder),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(time, style: _body(size: 12, color: _C.textMuted)),
        const SizedBox(height: 8),
        Text("${hourly['temperature_2m'][i]}°", style: _mono(size: 22)),
        const SizedBox(height: 6),
        Text("💧 ${hourly['relative_humidity_2m'][i]}%", style: _body(size: 11)),
        Text("🌧 ${hourly['precipitation_probability'][i]}%", style: _body(size: 11)),
      ]),
    );
  }

  Widget _dailyRow(int i) {
    final daily = weatherData!['daily'];
    final day = DateFormat('EEE').format(DateTime.parse(daily['time'][i]));
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(children: [
        if (i > 0) Divider(color: _C.glassBorder, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            SizedBox(width: 48, child: Text(day, style: _body(size: 14, color: Colors.white))),
            const Spacer(),
            Text("☔ ${daily['precipitation_probability_max'][i]}%", style: _body(size: 13, color: _C.cyan)),
            const SizedBox(width: 16),
            Text("${daily['temperature_2m_max'][i]}°", style: _body(size: 14, color: Colors.white)),
            Text(" / ", style: _body(size: 14, color: _C.textMuted)),
            Text("${daily['temperature_2m_min'][i]}°", style: _body(size: 14, color: _C.textMuted)),
          ]),
        ),
      ]),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label, style: _body(size: 13, color: color)),
    ]),
  );

  Widget _glassCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x26FFFFFF), Color(0x14FFFFFF)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _C.glassBorder),
    ),
    child: child,
  );

  Widget _pillButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_C.green, _C.cyan]),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _body(size: 15, color: _C.forestDeep).copyWith(fontWeight: FontWeight.w700)),
    ),
  );

  Widget _blob({double? top, double? bottom, double? left, double? right,
      required double size, required Color color, required double opacity}) =>
      Positioned(
        top: top, bottom: bottom, left: left, right: right,
        child: IgnorePointer(
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: opacity),
              boxShadow: [BoxShadow(color: color.withValues(alpha: opacity), blurRadius: 80, spreadRadius: 40)],
            ),
          ),
        ),
      );
}
