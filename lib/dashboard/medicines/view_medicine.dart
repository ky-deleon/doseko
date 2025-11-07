import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String type;
  final String dosage;
  final String? unit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? frequency;
  final List<TimeOfDay> intakeTimes;

  Medicine({
    required this.name,
    required this.type,
    required this.dosage,
    this.unit,
    this.startDate,
    this.endDate,
    this.frequency,
    required this.intakeTimes,
  });
}

class ViewMedicinePage extends StatelessWidget {
  final TextEditingController medicineNameController;
  final String medicineType;
  final String unit;
  final TextEditingController dosageController;
  final String doseAvailable; // New field for dosage available
  final DateTime? startDate;
  final DateTime? endDate;
  final String frequency;
  final List<TimeOfDay> intakeTimes;
  final String medicineId;
  final Function? onDelete; // Optional parameter
  final String selectedImage; // Add this field

  const ViewMedicinePage({
    Key? key,
    required this.medicineId,
    required this.medicineNameController,
    required this.medicineType,
    required this.unit,
    required this.dosageController,
    required this.doseAvailable, // Initialize the new field
    this.startDate,
    this.endDate,
    required this.frequency,
    required this.intakeTimes,
    required this.selectedImage, // Add it here
    this.onDelete, // Mark as optional
  }) : super(key: key);


  void _deleteMedicine(BuildContext context, String medicineId) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('medicines')
          .doc(medicineId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted successfully')),
      );

      if (onDelete != null) {
        onDelete!(); // Call only if provided
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medicine: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    debugPrint('Medicine ID in ViewMedicinePage: $medicineId'); // Log the ID
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "View Medicine",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff003399),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: (selectedImage.isNotEmpty)
                            ? Image.asset(
                          selectedImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                            : const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: Color(0xff003399),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicineNameController.text.isNotEmpty
                              ? medicineNameController.text
                              : 'No Name',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Text(
                          medicineType.isNotEmpty ? medicineType : 'No Type',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailSection('Dosage Unit', unit),
                _buildDetailSection('Dosage Amount', dosageController.text),
                _buildDetailSection('Dosage Available', doseAvailable), // Add here
                _buildDetailSection(
                  'Start Date',
                  startDate != null ? _formatDate(startDate!) : 'No Start Date',
                ),
                _buildDetailSection(
                  'End Date',
                  endDate != null ? _formatDate(endDate!) : 'No End Date',
                ),
                _buildDetailSection(
                  'Intake Times',
                  intakeTimes.isNotEmpty
                      ? intakeTimes
                      .map((time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}')
                      .join(', ')
                      : 'No Times',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: () {
            if (medicineId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Medicine ID is missing')),
              );
              return;
            }
            _deleteMedicine(context, medicineId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'DELETE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 53,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurStyle: BlurStyle.outer,
                blurRadius: 2.00,
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black54,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}