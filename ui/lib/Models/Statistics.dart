class cJobStatistics {
  final int total;
  final int open;
  final int pending;
  final int closed;
  final int rejected;
  final int expired;

  cJobStatistics({
    required this.total,
    required this.open,
    required this.pending,
    required this.closed,
    required this.rejected,
    required this.expired,
  });

  factory cJobStatistics.fromJson(Map<String, dynamic> json) {
    return cJobStatistics(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      pending: json['pending'] ?? 0,
      closed: json['closed'] ?? 0,
      rejected: json['rejected'] ?? 0,
      expired: json['expired'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'open': open,
      'pending': pending,
      'closed': closed,
      'rejected': rejected,
      'expired': expired,
    };
  }
}

class cApplicationStatistics {
  final int total;
  final int pending;
  final int accepted;
  final int rejected;

  cApplicationStatistics({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.rejected,
  });

  factory cApplicationStatistics.fromJson(Map<String, dynamic> json) {
    return cApplicationStatistics(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      accepted: json['accepted'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'accepted': accepted,
      'rejected': rejected,
    };
  }
}

class cUserStatistics {
  final int total;
  final int candidates;
  final int recruiters;
  final int activeUsers;
  final int blockedUsers;

  cUserStatistics({
    required this.total,
    required this.candidates,
    required this.recruiters,
    required this.activeUsers,
    required this.blockedUsers,
  });

  factory cUserStatistics.fromJson(Map<String, dynamic> json) {
    return cUserStatistics(
      total: json['total'] ?? 0,
      candidates: json['candidates'] ?? 0,
      recruiters: json['recruiters'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      blockedUsers: json['blockedUsers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'candidates': candidates,
      'recruiters': recruiters,
      'activeUsers': activeUsers,
      'blockedUsers': blockedUsers,
    };
  }
}

class cStatistics {
  cJobStatistics? jobStatistics;
  cApplicationStatistics? applicationStatistics;
  cUserStatistics? userStatistics;

  cStatistics({
    this.jobStatistics,
    this.applicationStatistics,
    this.userStatistics,
  });
}