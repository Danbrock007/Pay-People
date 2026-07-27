import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async =>
      _db ??= await openDatabase(join(await getDatabasesPath(), 'kapco_payroll.db'),
          version: 1, onCreate: _create);

  String hashPassword(String value) =>
      sha256.convert(utf8.encode('KAPCO::$value')).toString();

  Future<void> _create(Database db, int version) async {
    await db.execute('''CREATE TABLE employees(
      id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL, cnic TEXT, grade TEXT, department TEXT,
      designation TEXT, employee_type TEXT, work_location TEXT,
      joining_date TEXT, phone TEXT, email TEXT, address TEXT,
      emergency_contact TEXT, account_title TEXT, account_number TEXT,
      iban TEXT, bank TEXT, bank_address TEXT, basic_salary REAL DEFAULT 0,
      active INTEGER DEFAULT 1, created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');
    await db.execute('''CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL, display_name TEXT NOT NULL, role TEXT NOT NULL,
      employee_id INTEGER, permissions TEXT DEFAULT '[]', active INTEGER DEFAULT 1,
      must_change_password INTEGER DEFAULT 1, created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');
    await db.execute('''CREATE TABLE attendance(
      id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER NOT NULL,
      date TEXT NOT NULL, status TEXT NOT NULL, check_in TEXT, check_out TEXT,
      ot_hours REAL DEFAULT 0, notes TEXT, UNIQUE(employee_id,date))''');
    await db.execute('''CREATE TABLE leaves(
      id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER NOT NULL,
      type TEXT NOT NULL, start_date TEXT NOT NULL, end_date TEXT NOT NULL,
      days REAL NOT NULL, reason TEXT, status TEXT DEFAULT 'Pending',
      approved_by INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');
    await db.execute('''CREATE TABLE payrolls(
      id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER NOT NULL,
      month TEXT NOT NULL, payable_days INTEGER, leave_with_pay INTEGER DEFAULT 0,
      leave_without_pay INTEGER DEFAULT 0, absent INTEGER DEFAULT 0,
      arrears_days INTEGER DEFAULT 0, ot_hours REAL DEFAULT 0,
      ot_arrears_hours REAL DEFAULT 0, earnings TEXT NOT NULL, deductions TEXT NOT NULL,
      gross REAL NOT NULL, total_deductions REAL NOT NULL, net REAL NOT NULL,
      status TEXT DEFAULT 'Generated', generated_by INTEGER,
      generated_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(employee_id,month))''');
    await db.execute('''CREATE TABLE documents(
      id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id INTEGER NOT NULL,
      title TEXT NOT NULL, category TEXT, file_path TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');
    await db.execute('''CREATE TABLE settings(
      key TEXT PRIMARY KEY, value TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE audit_log(
      id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, action TEXT NOT NULL,
      details TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');

    final employeeId = await db.insert('employees', const Employee(
      employeeId: '214310',
      name: 'Muhammad Khurram Saeed',
      cnic: '00000-0000000-0',
      grade: 'MG3',
      department: 'Finance & IT',
      designation: 'Assistant Manager-I (Info Tech)',
      employeeType: 'Permanent',
      workLocation: 'Plant Site',
      joiningDate: '2025-07-01',
      phone: '0300-0000000',
      email: 'khurram@kapco.com.pk',
      accountTitle: 'Muhammad Khurram Saeed',
      accountNumber: '000000000000',
      iban: 'PK00HABB0000000000000000',
      bank: 'Habib Bank Ltd',
      bankAddress: 'N/A',
      basicSalary: 55000,
    ).toMap());
    final full = jsonEncode(allPermissions.keys.toList());
    await db.insert('users', {
      'username': 'admin',
      'password_hash': hashPassword('Admin@123'),
      'display_name': 'System Administrator',
      'role': 'Administrator',
      'permissions': full,
    });
    await db.insert('users', {
      'username': '214310',
      'password_hash': hashPassword('Employee@123'),
      'display_name': 'Muhammad Khurram Saeed',
      'role': 'Employee',
      'employee_id': employeeId,
      'permissions': jsonEncode(['dashboard.view', 'payroll.view']),
    });
    const settings = {
      'company_name': 'Kot Addu Power Company Limited',
      'app_name': 'KAPCO Payroll',
      'currency': 'PKR',
      'payroll_days': '30',
    };
    for (final e in settings.entries) {
      await db.insert('settings', {'key': e.key, 'value': e.value});
    }
    await savePayroll(Payroll(
      employeeDbId: employeeId,
      month: '2025-12',
      payableDays: 30,
      earnings: const {
        'Basic Salary': 55000,
        'House Rent Allowance': 22000,
        'Utility Allowance': 5500,
        'Conveyance Allowance': 8250,
        'Pension & Gratuity': 11000,
      },
      deductions: const {
        'Income Tax': 2774,
        'Provident Fund': 5500,
        'House Rent Deduction': 3976,
        'Water Charges': 6,
        'Gas Charges': 812,
        'Club Contribution': 800,
        'Fare Price Shop Deduction': 698,
        'EOBI': 400,
      },
    ), dbOverride: db);
  }

  Future<AppUser?> login(String username, String password) async {
    final db = await database;
    final rows = await db.query('users',
        where: 'LOWER(username)=? AND password_hash=? AND active=1',
        whereArgs: [username.trim().toLowerCase(), hashPassword(password)],
        limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    final permissions =
        (jsonDecode('${r['permissions']}') as List).map((e) => '$e').toSet();
    final user = AppUser(
      id: r['id'] as int,
      username: '${r['username']}',
      displayName: '${r['display_name']}',
      role: '${r['role']}',
      employeeId: r['employee_id'] as int?,
      permissions: permissions,
    );
    await log(user.id, 'LOGIN', 'Successful login');
    return user;
  }

  Future<List<Employee>> employees({String search = ''}) async {
    final db = await database;
    final rows = await db.query('employees',
        where: search.isEmpty
            ? null
            : 'name LIKE ? OR employee_id LIKE ? OR department LIKE ?',
        whereArgs: search.isEmpty
            ? null
            : List.filled(3, '%${search.trim()}%'),
        orderBy: 'name');
    return rows.map(Employee.fromMap).toList();
  }

  Future<int> saveEmployee(Employee employee) async {
    final db = await database;
    if (employee.id == null) return db.insert('employees', employee.toMap());
    await db.update('employees', employee.toMap(),
        where: 'id=?', whereArgs: [employee.id]);
    return employee.id!;
  }

  Future<Employee?> employee(int id) async {
    final db = await database;
    final r = await db.query('employees', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : Employee.fromMap(r.first);
  }

  Future<void> savePayroll(Payroll p, {Database? dbOverride}) async {
    final db = dbOverride ?? await database;
    await db.insert(
        'payrolls',
        {
          'employee_id': p.employeeDbId,
          'month': p.month,
          'payable_days': p.payableDays,
          'leave_with_pay': p.leaveWithPay,
          'leave_without_pay': p.leaveWithoutPay,
          'absent': p.absent,
          'arrears_days': p.arrearsDays,
          'ot_hours': p.otHours,
          'ot_arrears_hours': p.otArrearsHours,
          'earnings': jsonEncode(p.earnings),
          'deductions': jsonEncode(p.deductions),
          'gross': p.gross,
          'total_deductions': p.totalDeductions,
          'net': p.net,
          'status': p.status,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Payroll payrollFromMap(Map<String, Object?> r) => Payroll(
        id: r['id'] as int?,
        employeeDbId: r['employee_id'] as int,
        month: '${r['month']}',
        payableDays: r['payable_days'] as int? ?? 0,
        leaveWithPay: r['leave_with_pay'] as int? ?? 0,
        leaveWithoutPay: r['leave_without_pay'] as int? ?? 0,
        absent: r['absent'] as int? ?? 0,
        arrearsDays: r['arrears_days'] as int? ?? 0,
        otHours: (r['ot_hours'] as num?)?.toDouble() ?? 0,
        otArrearsHours: (r['ot_arrears_hours'] as num?)?.toDouble() ?? 0,
        earnings: (jsonDecode('${r['earnings']}') as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        deductions: (jsonDecode('${r['deductions']}') as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        status: '${r['status']}',
      );

  Future<List<Payroll>> payrolls({int? employeeId}) async {
    final db = await database;
    final rows = await db.query('payrolls',
        where: employeeId == null ? null : 'employee_id=?',
        whereArgs: employeeId == null ? null : [employeeId],
        orderBy: 'month DESC');
    return rows.map(payrollFromMap).toList();
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String name,
    required String role,
    int? employeeId,
    required Set<String> permissions,
  }) async {
    final db = await database;
    await db.insert('users', {
      'username': username.trim(),
      'password_hash': hashPassword(password),
      'display_name': name.trim(),
      'role': role,
      'employee_id': employeeId,
      'permissions': jsonEncode(permissions.toList()),
    });
  }

  Future<List<Map<String, Object?>>> users() async =>
      (await database).query('users', orderBy: 'display_name');

  Future<void> log(int? userId, String action, String details) async {
    await (await database).insert('audit_log',
        {'user_id': userId, 'action': action, 'details': details});
  }

  Future<Map<String, int>> dashboard() async {
    final db = await database;
    final employeeCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM employees WHERE active=1')) ?? 0;
    final now = DateTime.now().toIso8601String().substring(0, 10);
    Future<int> status(String value) async =>
        Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM attendance WHERE date=? AND status=?',
            [now, value])) ?? 0;
    return {
      'employees': employeeCount,
      'present': await status('Present'),
      'leave': await status('Leave'),
      'absent': await status('Absent'),
    };
  }
}
