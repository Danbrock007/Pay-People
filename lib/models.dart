class Employee {
  final int? id;
  final String employeeId;
  final String name;
  final String cnic;
  final String grade;
  final String department;
  final String designation;
  final String employeeType;
  final String workLocation;
  final String joiningDate;
  final String phone;
  final String email;
  final String address;
  final String emergencyContact;
  final String accountTitle;
  final String accountNumber;
  final String iban;
  final String bank;
  final String bankAddress;
  final double basicSalary;
  final bool active;

  const Employee({
    this.id,
    required this.employeeId,
    required this.name,
    this.cnic = '',
    this.grade = '',
    this.department = '',
    this.designation = '',
    this.employeeType = 'Permanent',
    this.workLocation = 'Plant Site',
    this.joiningDate = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.emergencyContact = '',
    this.accountTitle = '',
    this.accountNumber = '',
    this.iban = '',
    this.bank = '',
    this.bankAddress = '',
    this.basicSalary = 0,
    this.active = true,
  });

  factory Employee.fromMap(Map<String, Object?> m) => Employee(
        id: m['id'] as int?,
        employeeId: '${m['employee_id'] ?? ''}',
        name: '${m['name'] ?? ''}',
        cnic: '${m['cnic'] ?? ''}',
        grade: '${m['grade'] ?? ''}',
        department: '${m['department'] ?? ''}',
        designation: '${m['designation'] ?? ''}',
        employeeType: '${m['employee_type'] ?? ''}',
        workLocation: '${m['work_location'] ?? ''}',
        joiningDate: '${m['joining_date'] ?? ''}',
        phone: '${m['phone'] ?? ''}',
        email: '${m['email'] ?? ''}',
        address: '${m['address'] ?? ''}',
        emergencyContact: '${m['emergency_contact'] ?? ''}',
        accountTitle: '${m['account_title'] ?? ''}',
        accountNumber: '${m['account_number'] ?? ''}',
        iban: '${m['iban'] ?? ''}',
        bank: '${m['bank'] ?? ''}',
        bankAddress: '${m['bank_address'] ?? ''}',
        basicSalary: (m['basic_salary'] as num?)?.toDouble() ?? 0,
        active: (m['active'] as int? ?? 1) == 1,
      );

  Map<String, Object?> toMap() => {
        'employee_id': employeeId,
        'name': name,
        'cnic': cnic,
        'grade': grade,
        'department': department,
        'designation': designation,
        'employee_type': employeeType,
        'work_location': workLocation,
        'joining_date': joiningDate,
        'phone': phone,
        'email': email,
        'address': address,
        'emergency_contact': emergencyContact,
        'account_title': accountTitle,
        'account_number': accountNumber,
        'iban': iban,
        'bank': bank,
        'bank_address': bankAddress,
        'basic_salary': basicSalary,
        'active': active ? 1 : 0,
      };
}

class Payroll {
  final int? id;
  final int employeeDbId;
  final String month;
  final int payableDays;
  final int leaveWithPay;
  final int leaveWithoutPay;
  final int absent;
  final int arrearsDays;
  final double otHours;
  final double otArrearsHours;
  final Map<String, double> earnings;
  final Map<String, double> deductions;
  final String status;

  const Payroll({
    this.id,
    required this.employeeDbId,
    required this.month,
    required this.payableDays,
    this.leaveWithPay = 0,
    this.leaveWithoutPay = 0,
    this.absent = 0,
    this.arrearsDays = 0,
    this.otHours = 0,
    this.otArrearsHours = 0,
    required this.earnings,
    required this.deductions,
    this.status = 'Generated',
  });

  double get gross => earnings.values.fold(0, (a, b) => a + b);
  double get totalDeductions => deductions.values.fold(0, (a, b) => a + b);
  double get net => gross - totalDeductions;
}

class AppUser {
  final int id;
  final String username;
  final String displayName;
  final String role;
  final int? employeeId;
  final Set<String> permissions;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.employeeId,
    required this.permissions,
  });

  bool can(String permission) =>
      role == 'Administrator' || permissions.contains(permission);
}

const allPermissions = <String, String>{
  'dashboard.view': 'View dashboard',
  'employees.view': 'View employees',
  'employees.manage': 'Add/edit employees',
  'attendance.view': 'View attendance',
  'attendance.manage': 'Manage attendance',
  'leave.approve': 'Approve/reject leave',
  'payroll.view': 'View payroll',
  'payroll.generate': 'Generate/edit payroll',
  'payslip.all': 'View all payslips',
  'reports.view': 'View and export reports',
  'users.manage': 'Manage users and roles',
  'settings.manage': 'Manage settings and backup',
  'audit.view': 'View audit log',
};
