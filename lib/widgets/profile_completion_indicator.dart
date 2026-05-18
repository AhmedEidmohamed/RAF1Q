import 'package:flutter/material.dart';
import '../models/models.dart';

/// Profile completion indicator widget
/// Shows completion percentage and missing fields
class ProfileCompletionIndicator extends StatelessWidget {
  final ChildProfile? childProfile;
  final DoctorProfile? doctorProfile;

  const ProfileCompletionIndicator({
    Key? key,
    this.childProfile,
    this.doctorProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (childProfile != null) {
      return _buildChildProfileIndicator(context, childProfile!);
    } else if (doctorProfile != null) {
      return _buildDoctorProfileIndicator(context, doctorProfile!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildChildProfileIndicator(BuildContext context, ChildProfile profile) {
    final completion = _calculateChildProfileCompletion(profile);
    final missingFields = _getChildMissingFields(profile);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: _getCompletionColor(completion),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Completion',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${completion.round()}% Complete',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getCompletionColor(completion),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCompletionColor(completion).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    completion >= 80 ? 'Excellent' : 
                    completion >= 60 ? 'Good' : 
                    completion >= 40 ? 'Fair' : 'Needs Work',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getCompletionColor(completion),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(completion)),
            ),
            
            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Missing Information:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ...missingFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfileIndicator(BuildContext context, DoctorProfile profile) {
    final completion = _calculateDoctorProfileCompletion(profile);
    final missingFields = _getDoctorMissingFields(profile);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services_rounded,
                  color: _getCompletionColor(completion),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Completion',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${completion.round()}% Complete',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getCompletionColor(completion),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCompletionColor(completion).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    completion >= 80 ? 'Excellent' : 
                    completion >= 60 ? 'Good' : 
                    completion >= 40 ? 'Fair' : 'Needs Work',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getCompletionColor(completion),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(completion)),
            ),
            
            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Missing Information:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ...missingFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateChildProfileCompletion(ChildProfile profile) {
    int completedFields = 0;
    int totalFields = 15; // Total number of important fields

    // Basic info (required)
    if (profile.fullName.isNotEmpty) completedFields++;
    if (profile.age > 0) completedFields++;
    if (profile.gender.isNotEmpty) completedFields++;
    if (profile.governorate.isNotEmpty) completedFields++;
    if (profile.healthStatus.isNotEmpty) completedFields++;
    if (profile.username.isNotEmpty) completedFields++;
    if (profile.password.isNotEmpty) completedFields++;

    // Optional but important
    if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty) completedFields++;
    if (profile.parentName != null && profile.parentName!.isNotEmpty) completedFields++;
    if (profile.parentPhone != null && profile.parentPhone!.isNotEmpty) completedFields++;
    if (profile.address != null && profile.address!.isNotEmpty) completedFields++;
    if (profile.school != null && profile.school!.isNotEmpty) completedFields++;
    if (profile.iqLevel != null && profile.iqLevel!.isNotEmpty) completedFields++;
    if (profile.emergencyContact != null && profile.emergencyContact!.isNotEmpty) completedFields++;
    if (profile.emergencyPhone != null && profile.emergencyPhone!.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  double _calculateDoctorProfileCompletion(DoctorProfile profile) {
    int completedFields = 0;
    int totalFields = 13; // Total number of important fields

    // Basic info (required)
    if (profile.fullName.isNotEmpty) completedFields++;
    if (profile.username.isNotEmpty) completedFields++;
    if (profile.password.isNotEmpty) completedFields++;
    if (profile.specialization.isNotEmpty) completedFields++;
    if (profile.email.isNotEmpty) completedFields++;
    if (profile.phone.isNotEmpty) completedFields++;

    // Optional but important
    if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty) completedFields++;
    if (profile.clinicName != null && profile.clinicName!.isNotEmpty) completedFields++;
    if (profile.clinicAddress != null && profile.clinicAddress!.isNotEmpty) completedFields++;
    if (profile.qualifications != null && profile.qualifications!.isNotEmpty) completedFields++;
    if (profile.experience != null && profile.experience!.isNotEmpty) completedFields++;
    if (profile.licenseNumber != null && profile.licenseNumber!.isNotEmpty) completedFields++;
    if (profile.workingHours != null && profile.workingHours!.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  List<String> _getChildMissingFields(ChildProfile profile) {
    List<String> missing = [];

    if (profile.photoUrl == null || profile.photoUrl!.isEmpty) {
      missing.add('Profile Photo');
    }
    if (profile.parentName == null || profile.parentName!.isEmpty) {
      missing.add('Parent Name');
    }
    if (profile.parentPhone == null || profile.parentPhone!.isEmpty) {
      missing.add('Parent Phone');
    }
    if (profile.address == null || profile.address!.isEmpty) {
      missing.add('Address');
    }
    if (profile.school == null || profile.school!.isEmpty) {
      missing.add('School Information');
    }
    if (profile.emergencyContact == null || profile.emergencyContact!.isEmpty) {
      missing.add('Emergency Contact');
    }
    if (profile.emergencyPhone == null || profile.emergencyPhone!.isEmpty) {
      missing.add('Emergency Phone');
    }

    return missing;
  }

  List<String> _getDoctorMissingFields(DoctorProfile profile) {
    List<String> missing = [];

    if (profile.photoUrl == null || profile.photoUrl!.isEmpty) {
      missing.add('Profile Photo');
    }
    if (profile.clinicName == null || profile.clinicName!.isEmpty) {
      missing.add('Clinic/Hospital Name');
    }
    if (profile.clinicAddress == null || profile.clinicAddress!.isEmpty) {
      missing.add('Clinic Address');
    }
    if (profile.qualifications == null || profile.qualifications!.isEmpty) {
      missing.add('Qualifications');
    }
    if (profile.experience == null || profile.experience!.isEmpty) {
      missing.add('Experience');
    }
    if (profile.licenseNumber == null || profile.licenseNumber!.isEmpty) {
      missing.add('License Number');
    }
    if (profile.workingHours == null || profile.workingHours!.isEmpty) {
      missing.add('Working Hours');
    }

    return missing;
  }

  Color _getCompletionColor(double completion) {
    if (completion >= 80) {
      return Colors.green;
    } else if (completion >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
