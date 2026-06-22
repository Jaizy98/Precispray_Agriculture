import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

// ── B's design tokens (local copy) ───────────────────────
class _C {
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

TextStyle _heading({double size = 20, Color color = Colors.white}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w700, color: color);

TextStyle _body({double size = 14, Color color = _C.textBody}) =>
    GoogleFonts.manrope(fontSize: size, fontWeight: FontWeight.w500, color: color);

TextStyle _mono({double size = 24, Color color = _C.yellow}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: FontWeight.w600, color: color);
// ─────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool isRecording = false;
  List<LatLng> fieldPoints = [];
  double fieldArea = 0;

  double get areaInAcre    => fieldArea / 4046.86;
  double get areaInHectare => fieldArea / 10000;

  StreamSubscription<Position>? _posStream;
  LatLng _currentLocation = const LatLng(18.5204, 73.8567);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
      });
      // Pan the map to actual GPS location once we have it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_currentLocation, 18);
      });
    } catch (e) {
      debugPrint("LOCATION ERROR: $e");
    }
  }

  void _startMapping() {
    setState(() {
      isRecording = true;
      fieldPoints
        ..clear()
        ..add(_currentLocation);
    });
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      if (!isRecording) return;
      final point = LatLng(pos.latitude, pos.longitude);
      _currentLocation = point;
      if (pos.accuracy <= 10) {
        setState(() => fieldPoints.add(point));
      }
    });
  }

  double _calculateArea() {
    if (fieldPoints.length < 3) return 0;
    double area = 0;
    for (int i = 0; i < fieldPoints.length; i++) {
      final j = (i + 1) % fieldPoints.length;
      area += fieldPoints[i].latitude  * fieldPoints[j].longitude;
      area -= fieldPoints[j].latitude  * fieldPoints[i].longitude;
    }
    return area.abs() / 2 * 12365000000;
  }

  Future<void> _stopMapping() async {
    setState(() => isRecording = false);
    await _posStream?.cancel();
    _posStream = null;
    setState(() => fieldArea = _calculateArea());
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.forestDeep,
      body: Stack(
        children: [
          // ── background gradient ───────────────────────
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

          SafeArea(
            child: Column(
              children: [
                // ── top bar ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _iconBox(Icons.arrow_back),
                      ),
                      const SizedBox(width: 16),
                      Text("Field Mapping", style: _heading(size: 22)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── stats strip ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0x26FFFFFF), Color(0x14FFFFFF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _C.glassBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat("Area", "${fieldArea.toStringAsFixed(1)} m²", _C.cyan),
                        _divider(),
                        _stat("Acres", areaInAcre.toStringAsFixed(3), _C.green),
                        _divider(),
                        _stat("Hectares", areaInHectare.toStringAsFixed(3), _C.yellow),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── map ───────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation,
                          initialZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.precispray.app',
                          ),
                          if (fieldPoints.length > 1)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: fieldPoints,
                                  strokeWidth: 4,
                                  color: _C.cyan,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _C.orange.withValues(alpha: 0.25),
                                    border: Border.all(color: _C.orange, width: 2),
                                  ),
                                  child: const Icon(Icons.my_location, color: _C.orange, size: 22),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── control buttons ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: isRecording ? "Recording…" : "Start Mapping",
                          icon: Icons.play_arrow_rounded,
                          color: _C.green,
                          onTap: isRecording ? null : _startMapping,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          label: "Stop & Save",
                          icon: Icons.stop_rounded,
                          color: _C.orange,
                          onTap: isRecording ? _stopMapping : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: _mono(size: 16, color: color)),
      const SizedBox(height: 2),
      Text(label, style: _body(size: 11, color: _C.textMuted)),
    ],
  );

  Widget _divider() => Container(width: 1, height: 32, color: _C.glassBorder);

  Widget _iconBox(IconData icon) => Container(
    width: 46, height: 46,
    decoration: BoxDecoration(
      color: _C.glass,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.glassBorder),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? color : _C.glassBorder),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 18)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20,
                color: active ? _C.forestDeep : _C.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: _body(size: 14, color: active ? _C.forestDeep : _C.textMuted)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
