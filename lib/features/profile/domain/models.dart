/// Preferencias de notificaciones del usuario.
class NotificationSettings {
  const NotificationSettings({
    this.alertsPush = true,
    this.alertsEmail = false,
    this.medicationReminders = true,
    this.chatPush = true,
    this.digestDaily = false,
  });

  final bool alertsPush;
  final bool alertsEmail;
  final bool medicationReminders;
  final bool chatPush;
  final bool digestDaily;

  NotificationSettings copyWith({
    bool? alertsPush,
    bool? alertsEmail,
    bool? medicationReminders,
    bool? chatPush,
    bool? digestDaily,
  }) =>
      NotificationSettings(
        alertsPush: alertsPush ?? this.alertsPush,
        alertsEmail: alertsEmail ?? this.alertsEmail,
        medicationReminders: medicationReminders ?? this.medicationReminders,
        chatPush: chatPush ?? this.chatPush,
        digestDaily: digestDaily ?? this.digestDaily,
      );

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        alertsPush: (json['alerts_push'] ?? true) as bool,
        alertsEmail: (json['alerts_email'] ?? false) as bool,
        medicationReminders: (json['medication_reminders'] ?? true) as bool,
        chatPush: (json['chat_push'] ?? true) as bool,
        digestDaily: (json['digest_daily'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'alerts_push': alertsPush,
        'alerts_email': alertsEmail,
        'medication_reminders': medicationReminders,
        'chat_push': chatPush,
        'digest_daily': digestDaily,
      };
}
