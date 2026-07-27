import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'models.dart';
import 'payslip_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KapcoPayrollApp());
}

const kapcoGreen = Color(0xFF087F46);
const navy = Color(0xFF102B3F);
const bg = Color(0xFFF3F6F8);

class KapcoPayrollApp extends StatelessWidget {
  const KapcoPayrollApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KAPCO Payroll',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: kapcoGreen, primary: kapcoGreen, surface: Colors.white),
          scaffoldBackgroundColor: bg,
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8EC))),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        home: const LoginScreen(),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool obscure = true, loading = false;
  String? error;

  Future<void> login() async {
    setState(() { loading = true; error = null; });
    final user = await AppDatabase.instance.login(username.text, password.text);
    if (!mounted) return;
    setState(() => loading = false);
    if (user == null) {
      setState(() => error = 'Invalid username or password');
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => Shell(user: user)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 86,
                          decoration: BoxDecoration(
                              color: kapcoGreen,
                              borderRadius: BorderRadius.circular(22)),
                          alignment: Alignment.center,
                          child: const Text('KAPCO',
                              style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 34, letterSpacing: 3)),
                        ),
                        const SizedBox(height: 24),
                        const Text('Welcome back',
                            style: TextStyle(fontSize: 26,
                                fontWeight: FontWeight.w800, color: navy)),
                        const SizedBox(height: 5),
                        const Text('Sign in to KAPCO Payroll',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 24),
                        TextField(controller: username,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              labelText: 'Username / Employee ID',
                              prefixIcon: Icon(Icons.person_outline))),
                        const SizedBox(height: 14),
                        TextField(controller: password, obscureText: obscure,
                          onSubmitted: (_) => login(),
                          decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                  onPressed: () => setState(() => obscure = !obscure),
                                  icon: Icon(obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined)))),
                        if (error != null) Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(error!, style: const TextStyle(color: Colors.red))),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: loading ? null : login,
                          style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(17),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: loading
                              ? const SizedBox.square(dimension: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('SIGN IN',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        const Text('Test accounts', style: TextStyle(
                            fontWeight: FontWeight.w700, color: navy)),
                        const SizedBox(height: 7),
                        const SelectableText(
                            'Administrator: admin / Admin@123\n'
                            'Employee: 214310 / Employee@123',
                            style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class Shell extends StatefulWidget {
  final AppUser user;
  const Shell({super.key, required this.user});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  late final items = <({String title, IconData icon, Widget page, String permission})>[
    (title: 'Dashboard', icon: Icons.dashboard_rounded,
      page: DashboardPage(user: widget.user), permission: 'dashboard.view'),
    (title: 'Employees', icon: Icons.groups_rounded,
      page: EmployeesPage(user: widget.user), permission: 'employees.view'),
    (title: 'Attendance', icon: Icons.fact_check_rounded,
      page: const PlaceholderPage(title: 'Attendance & Leave',
        icon: Icons.fact_check_rounded,
        text: 'Daily attendance, shifts, overtime and leave approvals'),
      permission: 'attendance.view'),
    (title: 'Payroll', icon: Icons.account_balance_wallet_rounded,
      page: PayrollPage(user: widget.user), permission: 'payroll.view'),
    (title: 'Reports', icon: Icons.analytics_rounded,
      page: const PlaceholderPage(title: 'Reports & Analytics',
        icon: Icons.analytics_rounded,
        text: 'Payroll, attendance, tax, department and bank reports'),
      permission: 'reports.view'),
    (title: 'Users & Roles', icon: Icons.admin_panel_settings_rounded,
      page: UsersPage(user: widget.user), permission: 'users.manage'),
    (title: 'Settings', icon: Icons.settings_rounded,
      page: const PlaceholderPage(title: 'Settings & Backup',
        icon: Icons.settings_rounded,
        text: 'Company, payroll rules, allowances, deductions and database backup'),
      permission: 'settings.manage'),
  ].where((x) => widget.user.can(x.permission)).toList();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    final nav = items.map((x) => NavigationRailDestination(
        icon: Icon(x.icon), selectedIcon: Icon(x.icon), label: Text(x.title))).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('KAPCO Payroll', style: TextStyle(
              color: navy, fontWeight: FontWeight.w800, fontSize: 19)),
          Text(items[index].title,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ]),
        actions: [
          CircleAvatar(backgroundColor: kapcoGreen.withValues(alpha: .12),
              child: Text(widget.user.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: kapcoGreen,
                      fontWeight: FontWeight.w800))),
          const SizedBox(width: 9),
          if (wide) Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.user.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              Text(widget.user.role,
                  style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ]),
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == -1) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              } else {
                setState(() => index = value);
              }
            },
            itemBuilder: (_) => [
              if (!wide)
                ...List.generate(items.length > 5 ? items.length - 5 : 0, (i) {
                  final actual = i + 5;
                  return PopupMenuItem(
                    value: actual,
                    child: ListTile(
                        leading: Icon(items[actual].icon),
                        title: Text(items[actual].title)),
                  );
                }),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: -1,
                  child: ListTile(leading: Icon(Icons.logout),
                      title: Text('Sign out'))),
            ],
          ),
        ],
      ),
      body: Row(children: [
        if (wide)
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width >= 1100,
            backgroundColor: Colors.white,
            selectedIndex: index,
            onDestinationSelected: (v) => setState(() => index = v),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: CircleAvatar(radius: 25, backgroundColor: kapcoGreen,
                child: Text('K', style: TextStyle(color: Colors.white,
                    fontSize: 24, fontWeight: FontWeight.w900))),
            ),
            destinations: nav,
          ),
        Expanded(child: items[index].page),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: items.take(5).map((x) =>
            NavigationDestination(icon: Icon(x.icon), label: x.title)).toList(),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final AppUser user;
  const DashboardPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, int>>(
    future: AppDatabase.instance.dashboard(),
    builder: (_, s) {
      final d = s.data ?? {};
      return ListView(padding: const EdgeInsets.all(20), children: [
        Text('Good ${DateTime.now().hour < 12 ? 'morning' : 'afternoon'}, ${user.displayName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 5),
        Text(DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (_, c) {
          final count = c.maxWidth > 900 ? 4 : 2;
          final cards = [
            ('Total Employees', '${d['employees'] ?? 0}', Icons.groups_rounded, kapcoGreen),
            ('Present Today', '${d['present'] ?? 0}', Icons.check_circle_rounded, Colors.blue),
            ('On Leave', '${d['leave'] ?? 0}', Icons.event_busy_rounded, Colors.orange),
            ('Absent', '${d['absent'] ?? 0}', Icons.cancel_rounded, Colors.red),
          ];
          return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: count, mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: c.maxWidth > 600 ? 2.2 : 1.25,
            children: cards.map((x) => StatCard(
                title: x.$1, value: x.$2, icon: x.$3, color: x.$4)).toList());
        }),
        const SizedBox(height: 18),
        const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quick overview', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w800, color: navy)),
          SizedBox(height: 16),
          ListTile(contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFE8F5EE),
                  child: Icon(Icons.account_balance_wallet, color: kapcoGreen)),
              title: Text('Payroll is ready'),
              subtitle: Text('Generate, review and issue monthly salary slips'),
              trailing: Icon(Icons.chevron_right)),
          Divider(),
          ListTile(contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFE8F1FB),
                  child: Icon(Icons.verified_user, color: Colors.blue)),
              title: Text('Role-based security'),
              subtitle: Text('Every administrative action is permission controlled'),
              trailing: Icon(Icons.chevron_right)),
        ]))),
      ]);
    });
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.title, required this.value,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(17),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      CircleAvatar(backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color)),
      Text(value, style: const TextStyle(fontSize: 26,
          fontWeight: FontWeight.w900, color: navy)),
      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  ));
}

class EmployeesPage extends StatefulWidget {
  final AppUser user;
  const EmployeesPage({super.key, required this.user});
  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  String search = '';
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      Expanded(child: TextField(onChanged: (v) => setState(() => search = v),
          decoration: const InputDecoration(hintText: 'Search employee, ID or department',
              prefixIcon: Icon(Icons.search)))),
      if (widget.user.can('employees.manage')) ...[
        const SizedBox(width: 10),
        FilledButton.icon(onPressed: () => showDialog(context: context,
            builder: (_) => const EmployeeForm()),
            icon: const Icon(Icons.person_add_alt_1), label: const Text('Add Employee')),
      ],
    ])),
    Expanded(child: FutureBuilder<List<Employee>>(
      future: AppDatabase.instance.employees(search: search),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return RefreshIndicator(onRefresh: () async => setState(() {}),
          child: ListView.separated(padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            itemCount: s.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = s.data![i];
              return Card(child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(backgroundColor: kapcoGreen.withValues(alpha: .12),
                    child: Text(e.name.substring(0, 1),
                        style: const TextStyle(color: kapcoGreen, fontWeight: FontWeight.w800))),
                title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${e.employeeId} • ${e.designation}\n${e.department} • ${e.workLocation}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
              ));
            }));
      },
    ))
  ]);
}

class EmployeeForm extends StatefulWidget {
  const EmployeeForm({super.key});
  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}
class _EmployeeFormState extends State<EmployeeForm> {
  final form = GlobalKey<FormState>();
  final ctrls = List.generate(13, (_) => TextEditingController());
  final labels = ['Employee ID','Full Name','CNIC','Grade','Department','Designation',
    'Work Location','Joining Date (YYYY-MM-DD)','Phone','Email','Bank Account',
    'IBAN','Basic Salary'];
  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    await AppDatabase.instance.saveEmployee(Employee(employeeId: ctrls[0].text,
      name: ctrls[1].text, cnic: ctrls[2].text, grade: ctrls[3].text,
      department: ctrls[4].text, designation: ctrls[5].text,
      workLocation: ctrls[6].text, joiningDate: ctrls[7].text,
      phone: ctrls[8].text, email: ctrls[9].text, accountNumber: ctrls[10].text,
      iban: ctrls[11].text, basicSalary: double.tryParse(ctrls[12].text) ?? 0));
    if (mounted) Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New Employee'),
    content: SizedBox(
      width: 600,
      child: Form(
        key: form,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              labels.length,
              (i) => SizedBox(
                width: 275,
                child: TextFormField(
                  controller: ctrls[i],
                  keyboardType: i == 12 ? TextInputType.number : null,
                  validator: i < 2
                      ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
                      : null,
                  decoration: InputDecoration(labelText: labels[i]),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: save, child: const Text('Save Employee'))],
  );
}

class PayrollPage extends StatefulWidget {
  final AppUser user;
  const PayrollPage({super.key, required this.user});
  @override
  State<PayrollPage> createState() => _PayrollPageState();
}
class _PayrollPageState extends State<PayrollPage> {
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Payroll>>(
    future: AppDatabase.instance.payrolls(
        employeeId: widget.user.role == 'Employee' ? widget.user.employeeId : null),
    builder: (_, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Payroll & Salary Slips', style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.w800, color: navy)),
              Text('Review salary and securely issue payslips',
                  style: TextStyle(color: Colors.black54))])),
          if (widget.user.can('payroll.generate'))
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add),
                label: const Text('Generate Payroll')),
        ]),
        const SizedBox(height: 16),
        ...s.data!.map((p) => FutureBuilder<Employee?>(
          future: AppDatabase.instance.employee(p.employeeDbId),
          builder: (_, es) {
            final e = es.data;
            if (e == null) return const SizedBox();
            return Card(child: Padding(padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  CircleAvatar(backgroundColor: kapcoGreen.withValues(alpha: .12),
                      child: const Icon(Icons.receipt_long, color: kapcoGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(e.name, style: const TextStyle(
                        fontWeight: FontWeight.w800, color: navy)),
                      Text('${e.employeeId} • ${DateFormat('MMMM yyyy').format(DateTime.parse('${p.month}-01'))}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12))])),
                  Chip(label: Text(p.status)),
                ]),
                const Divider(height: 26),
                Row(children: [
                  Expanded(child: _Money(label: 'Gross', value: p.gross)),
                  Expanded(child: _Money(label: 'Deductions', value: p.totalDeductions)),
                  Expanded(child: _Money(label: 'Net Pay', value: p.net, strong: true)),
                ]),
                const SizedBox(height: 13),
                Wrap(spacing: 8, children: [
                  OutlinedButton.icon(onPressed: () async {
                    final bytes = await PayslipService.build(e, p);
                    if (!context.mounted) return;
                    showDialog(context: context, builder: (_) => Dialog(
                      child: SizedBox(width: 850, height: 650,
                        child: PdfPreviewBox(bytes: bytes, employee: e, payroll: p))));
                  }, icon: const Icon(Icons.visibility), label: const Text('View')),
                  OutlinedButton.icon(onPressed: () => PayslipService.printSlip(e, p),
                      icon: const Icon(Icons.print), label: const Text('Print / PDF')),
                  FilledButton.icon(onPressed: () => PayslipService.share(e, p),
                      icon: const Icon(Icons.share), label: const Text('WhatsApp Share')),
                ])
              ])));
          },
        )),
      ]);
    });
}

class PdfPreviewBox extends StatelessWidget {
  final List<int> bytes;
  final Employee employee;
  final Payroll payroll;
  const PdfPreviewBox({super.key, required this.bytes,
      required this.employee, required this.payroll});
  @override
  Widget build(BuildContext context) => Column(children: [
    AppBar(title: Text('Salary Slip • ${employee.name}'),
      leading: IconButton(onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close)),
      actions: [
        IconButton(onPressed: () => PayslipService.printSlip(employee, payroll),
            icon: const Icon(Icons.print)),
        IconButton(onPressed: () => PayslipService.share(employee, payroll),
            icon: const Icon(Icons.share)),
      ]),
    Expanded(child: Container(color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
        SizedBox(height: 12),
        Text('Salary slip generated successfully'),
        Text('Use Print / PDF or Share to open the document',
            style: TextStyle(color: Colors.black54)),
      ]))),
  ]);
}

class _Money extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;
  const _Money({required this.label, required this.value, this.strong = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      Text('PKR ${NumberFormat('#,##0.00').format(value)}',
          style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: strong ? kapcoGreen : navy))]);
}

class UsersPage extends StatefulWidget {
  final AppUser user;
  const UsersPage({super.key, required this.user});
  @override
  State<UsersPage> createState() => _UsersPageState();
}
class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, Object?>>>(
    future: AppDatabase.instance.users(),
    builder: (_, s) => ListView(padding: const EdgeInsets.all(18), children: [
      Row(children: [const Expanded(child: Text('Users & Access Control',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: navy))),
        FilledButton.icon(onPressed: () async {
          await showDialog(context: context, builder: (_) => const UserForm());
          setState(() {});
        }, icon: const Icon(Icons.person_add), label: const Text('Create Account'))]),
      const SizedBox(height: 16),
      ...(s.data ?? []).map((u) => Card(child: ListTile(
        leading: CircleAvatar(backgroundColor: kapcoGreen.withValues(alpha: .12),
            child: const Icon(Icons.person, color: kapcoGreen)),
        title: Text('${u['display_name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('@${u['username']} • ${u['role']}'),
        trailing: Chip(label: Text((u['active'] as int? ?? 1) == 1 ? 'Active' : 'Disabled')),
      ))),
    ]),
  );
}

class UserForm extends StatefulWidget {
  const UserForm({super.key});
  @override
  State<UserForm> createState() => _UserFormState();
}
class _UserFormState extends State<UserForm> {
  final username = TextEditingController(), name = TextEditingController(),
      password = TextEditingController();
  String role = 'HR';
  final selected = <String>{'dashboard.view', 'employees.view'};
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create User Account'),
    content: SizedBox(width: 600, height: 520, child: SingleChildScrollView(child: Column(children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Display Name')),
      const SizedBox(height: 10),
      TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
      const SizedBox(height: 10),
      TextField(controller: password, obscureText: true,
          decoration: const InputDecoration(labelText: 'Temporary Password')),
      const SizedBox(height: 10),
      DropdownButtonFormField(initialValue: role, items: ['HR','Payroll Officer','Manager','Auditor','Employee']
          .map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (v) => setState(() => role = v!),
          decoration: const InputDecoration(labelText: 'Role')),
      const SizedBox(height: 16),
      const Align(alignment: Alignment.centerLeft,
          child: Text('Module permissions', style: TextStyle(fontWeight: FontWeight.w800))),
      ...allPermissions.entries.map((x) => CheckboxListTile(
        dense: true, value: selected.contains(x.key), title: Text(x.value),
        onChanged: (v) => setState(() => v! ? selected.add(x.key) : selected.remove(x.key)))),
    ]))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () async {
        await AppDatabase.instance.createUser(username: username.text,
            password: password.text, name: name.text, role: role,
            permissions: selected);
        if (mounted) Navigator.pop(context);
      }, child: const Text('Create Account')),
    ],
  );
}

class PlaceholderPage extends StatelessWidget {
  final String title, text;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title,
      required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Center(child: Card(
    margin: const EdgeInsets.all(24),
    child: Padding(padding: const EdgeInsets.all(40), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(radius: 38, backgroundColor: kapcoGreen.withValues(alpha: .12),
          child: Icon(icon, color: kapcoGreen, size: 38)),
      const SizedBox(height: 18),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(
          fontSize: 23, fontWeight: FontWeight.w800, color: navy)),
      const SizedBox(height: 8),
      Text(text, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54)),
    ])),
  ));
}
