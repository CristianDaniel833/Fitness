import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_point.dart';

class OpenStreetMapWidget extends StatefulWidget {
  const OpenStreetMapWidget({
    super.key,
    required this.routePoints,
    this.fallbackCenter = const LatLng(19.4326, -99.1332),
    this.autoFollow = true,
  });

  final List<RoutePoint> routePoints;
  final LatLng fallbackCenter;
  final bool autoFollow;

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _lastMovedPoint;

  @override
  void didUpdateWidget(covariant OpenStreetMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.autoFollow || widget.routePoints.isEmpty) return;

    final latest = LatLng(
      widget.routePoints.last.latitude,
      widget.routePoints.last.longitude,
    );

    if (_lastMovedPoint == null ||
        _lastMovedPoint!.latitude != latest.latitude ||
        _lastMovedPoint!.longitude != latest.longitude) {
      _lastMovedPoint = latest;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(latest, _mapController.camera.zoom);
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.routePoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    final center = points.isNotEmpty ? points.last : widget.fallbackCenter;

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.fitness',
            ),
            if (points.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 4,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            if (points.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: points.last,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.location_pin,
                      size: 36,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}