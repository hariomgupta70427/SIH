// API service for backend communication
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/part.dart';
import '../models/inspection.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Backend API URL
  
  // HTTP client with timeout
  static final http.Client _client = http.Client();
  
  // Common headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Fetch all parts from inventory
  static Future<List<Part>> fetchParts({int page = 1, int limit = 50}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/parts?page=$page&limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Part.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load parts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching parts: $e');
      // Return mock data for demonstration
      return _getMockParts();
    }
  }

  // Fetch all inspections
  static Future<List<Inspection>> fetchInspections({int page = 1, int limit = 50}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/inspections?page=$page&limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Inspection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inspections: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching inspections: $e');
      // Return mock data for demonstration
      return _getMockInspections();
    }
  }

  // Create new part
  static Future<Part> createPart(Part part) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/parts'),
        headers: _headers,
        body: json.encode(part.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return Part.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create part: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating part: $e');
      rethrow;
    }
  }

  // Update existing part
  static Future<Part> updatePart(String id, Part part) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/parts/$id'),
        headers: _headers,
        body: json.encode(part.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Part.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update part: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating part: $e');
      rethrow;
    }
  }

  // Delete part
  static Future<void> deletePart(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/parts/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete part: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting part: $e');
      rethrow;
    }
  }

  // Create new inspection
  static Future<Inspection> createInspection(Inspection inspection) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/inspections'),
        headers: _headers,
        body: json.encode(inspection.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return Inspection.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create inspection: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating inspection: $e');
      rethrow;
    }
  }

  // Mock data for demonstration when API is unavailable
  static List<Part> _getMockParts() {
    return [
      Part(
        id: '1',
        name: 'Brake Pad Assembly',
        partNumber: 'BP-2024-001',
        category: 'Brake System',
        quantity: 45,
        price: 2500.00,
        status: 'active',
        location: 'Warehouse-A-01',
        vendorName: 'Railway Parts Ltd',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Part(
        id: '2',
        name: 'Signal Light LED',
        partNumber: 'SL-2024-002',
        category: 'Electrical',
        quantity: 23,
        price: 8500.00,
        status: 'active',
        location: 'Warehouse-B-03',
        vendorName: 'Metro Components',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Part(
        id: '3',
        name: 'Rail Fastener Kit',
        partNumber: 'RF-2024-003',
        category: 'Track System',
        quantity: 78,
        price: 450.00,
        status: 'active',
        location: 'Warehouse-C-05',
        vendorName: 'Track Systems Inc',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  static List<Inspection> _getMockInspections() {
    return [
      Inspection(
        id: '1',
        partId: '1',
        partName: 'Brake Pad Assembly',
        inspectorName: 'Alice Johnson',
        inspectionDate: DateTime.now().subtract(const Duration(days: 5)),
        result: 'passed',
        score: 95,
        remarks: 'Excellent condition, no defects found',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Inspection(
        id: '2',
        partId: '2',
        partName: 'Signal Light LED',
        inspectorName: 'Bob Smith',
        inspectionDate: DateTime.now().subtract(const Duration(days: 3)),
        result: 'failed',
        score: 65,
        remarks: 'Minor electrical issues detected',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Inspection(
        id: '3',
        partId: '3',
        partName: 'Rail Fastener Kit',
        inspectorName: 'Carol Davis',
        inspectionDate: DateTime.now().subtract(const Duration(days: 1)),
        result: 'passed',
        score: 88,
        remarks: 'Good condition, minor wear observed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Cleanup resources
  static void dispose() {
    _client.close();
  }
}