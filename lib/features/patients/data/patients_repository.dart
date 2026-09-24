import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/models.dart';
import '../domain/models.dart';

abstract class PatientsRepository {
  Future<List<PatientCard>> listMyPatients();
  Future<Patient> getPatient(String patientId);
  Future<Patient> createPatient(NewPatient data);
  Future<Invitation> invite({
    required String patientId,
    required RoleType role,
    String? email,
  });
  Future<void> acceptInvitation(String token);
  Future<WearableStatus> wearableStatus(String patientId);
}

// ---------------------------------------------------------------------------
// HTTP
// ---------------------------------------------------------------------------
class PatientsRepositoryHttp implements PatientsRepository {
  PatientsRepositoryHttp(this._api);
  final ApiClient _api;

  @override
  Future<List<PatientCard>> listMyPatients() async {
    final data = await _api.get<Map<String, dynamic>>('/patients');
    return ((data['items'] ?? []) as List)
        .map((e) => PatientCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Patient> getPatient(String patientId) async {
    final data = await _api.get<Map<String, dynamic>>('/patients/$patientId');
    return Patient.fromJson(data);
  }

  @override
  Future<Patient> createPatient(NewPatient data) async {
    final res =
        await _api.post<Map<String, dynamic>>('/patients', data: data.toJson());
    return getPatient(res['patient_id'] as String);
  }

  @override
  Future<Invitation> invite(
      {required String patientId, required RoleType role, String? email}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/patients/$patientId/invitations',
      data: {'role': role.apiValue, if (email != null) 'email': email},
    );
    return Invitation.fromJson(res);
  }

  @override
  Future<void> acceptInvitation(String token) =>
      _api.post<void>('/invitations/accept', data: {'token': token});

  @override
  Future<WearableStatus> wearableStatus(String patientId) async {
    final data =
        await _api.get<Map<String, dynamic>>('/patients/$patientId/wearable/status');
    return WearableStatus.fromJson(data);
  }
}

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------
class PatientsRepositoryMock implements PatientsRepository {
  final Map<String, Patient> _patients = {
    'p-elena': Patient(
      patientId: 'p-elena',
      fullName: 'Elena Ramírez',
      birthDate: DateTime(1948, 3, 12),
      sex: 'female',
      conditions: const ['Hipertensión', 'Artrosis'],
      wearable: WearableStatus(
        wearableId: 'w-1',
        lastSyncAt: DateTime.now().subtract(const Duration(minutes: 18)),
        batteryPct: 72,
      ),
    ),
    'p-jose': Patient(
      patientId: 'p-jose',
      fullName: 'José Ramírez',
      birthDate: DateTime(1945, 11, 2),
      sex: 'male',
      conditions: const ['Diabetes tipo 2'],
      wearable: WearableStatus(
        wearableId: 'w-2',
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 3)),
        batteryPct: 15,
        isStale: true,
      ),
    ),
  };

  @override
  Future<List<PatientCard>> listMyPatients() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      const PatientCard(
        patientId: 'p-elena',
        fullName: 'Elena Ramírez',
        role: RoleType.family,
        wellbeingStatus: WellbeingStatus.ok,
      ),
      const PatientCard(
        patientId: 'p-jose',
        fullName: 'José Ramírez',
        role: RoleType.family,
        wellbeingStatus: WellbeingStatus.warning,
        activeAlertsCount: 1,
        topReason: 'Wearable sin datos desde hace 3 h',
      ),
    ];
  }

  @override
  Future<Patient> getPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final p = _patients[patientId];
    if (p == null) {
      throw ApiException(
          statusCode: 404,
          code: 'NOT_FOUND',
          message: 'El recurso solicitado no existe o no está disponible.');
    }
    return p;
  }

  @override
  Future<Patient> createPatient(NewPatient data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'p-${DateTime.now().millisecondsSinceEpoch}';
    final patient = Patient(
      patientId: id,
      fullName: data.fullName,
      birthDate: data.birthDate,
      sex: data.sex,
      conditions: data.conditions,
      notes: data.notes,
    );
    _patients[id] = patient;
    return patient;
  }

  @override
  Future<Invitation> invite(
      {required String patientId, required RoleType role, String? email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final token = 'inv-${DateTime.now().millisecondsSinceEpoch}';
    return Invitation(
      invitationId: 'i-1',
      token: token,
      inviteUrl: 'https://app.agecare.app/invite/$token',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  @override
  Future<void> acceptInvitation(String token) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<WearableStatus> wearableStatus(String patientId) async {
    final p = await getPatient(patientId);
    return p.wearable ?? const WearableStatus();
  }
}

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  if (AppConfig.useMocks) return PatientsRepositoryMock();
  return PatientsRepositoryHttp(ref.watch(apiClientProvider));
});
