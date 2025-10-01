class EntitlementCompanyInfo {
  final int seatsAllowed;
  final int seatsUsed;

  EntitlementCompanyInfo({required this.seatsAllowed, required this.seatsUsed});

  factory EntitlementCompanyInfo.fromJson(Map<String, dynamic> j) => EntitlementCompanyInfo(
    seatsAllowed: (j['seats_allowed'] ?? 0) as int,
    seatsUsed: (j['seats_used'] ?? 0) as int,
  );
}

class EntitlementSummary {
  final int companiesAllowed;
  final int companiesUsed;
  final int baseUsersPerCompany;
  final Map<String, EntitlementCompanyInfo> perCompany; // key: companyId as string
  final String subscriptionStatus; // none | active | grace | past_due | expired | canceled
  final DateTime? graceUntil;
  final DateTime? currentPeriodEnd;

  EntitlementSummary({
    required this.companiesAllowed,
    required this.companiesUsed,
    required this.baseUsersPerCompany,
    required this.perCompany,
    required this.subscriptionStatus,
    required this.graceUntil,
    required this.currentPeriodEnd,
  });

  factory EntitlementSummary.fromJson(Map<String, dynamic> j) {
    final pcRaw = (j['per_company'] ?? {}) as Map<String, dynamic>;
    final pc = <String, EntitlementCompanyInfo>{};
    pcRaw.forEach((k, v) => pc[k] = EntitlementCompanyInfo.fromJson(Map<String, dynamic>.from(v)));

    DateTime? _dt(dynamic v) => v == null ? null : DateTime.parse(v as String).toLocal();

    return EntitlementSummary(
      companiesAllowed: (j['companies_allowed'] ?? 0) as int,
      companiesUsed: (j['companies_used'] ?? 0) as int,
      baseUsersPerCompany: (j['base_users_per_company'] ?? 20) as int,
      perCompany: pc,
      subscriptionStatus: (j['subscription_status'] ?? 'none') as String,
      graceUntil: _dt(j['grace_until']),
      currentPeriodEnd: _dt(j['current_period_end']),
    );
  }
}