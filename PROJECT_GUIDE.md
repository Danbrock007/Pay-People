# KAPCO Payroll — Administrator Guide

## Test access

| Account | Username | Password | Access |
|---|---|---|---|
| Administrator | `admin` | `Admin@123` | Complete system |
| Employee | `214310` | `Employee@123` | Own dashboard and salary slips |

## Administrative workflow

1. Sign in with the Administrator account.
2. Add employees from **Employees → Add Employee**.
3. Open **Users & Roles → Create Account** to make HR, Payroll Officer,
   Manager, Auditor or Employee accounts.
4. Select individual module permissions for each account.
5. Maintain attendance, leave and overtime before payroll generation.
6. Review earnings and deductions, generate monthly payroll, then issue the
   salary slip.
7. Use **Print / PDF** to print or download and **WhatsApp Share** to share the
   generated PDF through WhatsApp or another installed app.

## Salary slip fields

- Employee ID, employee name, CNIC, grade, department and designation
- Employee type, work location and joining date
- Payable days, paid/unpaid leave, absence, arrears and overtime
- Configurable payment/allowance and deduction heads
- Gross pay, total deductions, net pay and amount in words
- Account number, IBAN, bank and branch/address
- Confidentiality and computer-generated-document notice

## Security

- Passwords are stored as salted SHA-256 hashes, never as plain text.
- Module access is checked against the signed-in user's permissions.
- Employee accounts are linked to an employee record.
- Administrative activity is supported by a local audit-log table.
- The database remains on the device in SQLite.

Change the default passwords before production use.
