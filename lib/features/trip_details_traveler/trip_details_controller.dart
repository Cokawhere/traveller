// lib/features/trip_details/logic/trip_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:traveller/features/creat_trip/trip_service.dart';

class TripDetailsController extends GetxController {
  final String tripId;
  final TripService _tripService = TripService();

  TripDetailsController({required this.tripId});

  // Observable variables
  final Rx<TripModel?> trip = Rx<TripModel?>(null);
  final RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingRequests = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTripDetails();
    loadRequests();
  }

  // Load trip details
  Future<void> loadTripDetails() async {
    try {
      isLoading.value = true;
      final tripData = await _tripService.getTripById(tripId);
      
      if (tripData == null) {
        Get.snackbar(
          'Error',
          'Trip not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      trip.value = tripData;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load trip details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load requests
  Future<void> loadRequests() async {
    try {
      isLoadingRequests.value = true;
      final loadedRequests = await _tripService.getTripRequests(tripId);
      requests.value = loadedRequests;
    } catch (e) {
      print('Error loading requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  // Approve request
  Future<void> approveRequest(String requestId, String companionName) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final error = await _tripService.approveRequest(tripId, requestId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Request from $companionName approved!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        // Reload data
        await loadTripDetails();
        await loadRequests();
      } else {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to approve request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Reject request
  Future<void> rejectRequest(String requestId, String companionName) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final error = await _tripService.rejectRequest(tripId, requestId);

      Get.back();

      if (error == null) {
        Get.snackbar(
          'Success',
          'Request from $companionName rejected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
        );

        // Reload requests
        await loadRequests();
      } else {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to reject request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  // Get pending requests
  List<Map<String, dynamic>> getPendingRequests() {
    return requests.where((req) => req['status'] == 'pending').toList();
  }

  // Get accepted requests
  List<Map<String, dynamic>> getAcceptedRequests() {
    return requests.where((req) => req['status'] == 'accepted').toList();
  }

  // Get rejected requests
  List<Map<String, dynamic>> getRejectedRequests() {
    return requests.where((req) => req['status'] == 'rejected').toList();
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadTripDetails();
    await loadRequests();
  }
}