# KAPCO Payroll

Professional offline Flutter payroll and HR application for Android.

## Default test accounts

- Administrator: `admin` / `Admin@123`
- Employee: `214310` / `Employee@123`

Change both passwords after first login.

## Features

- Role-based login and granular permissions
- Employee master records, documents and bank details
- Attendance, leave and overtime
- Monthly payroll generation with configurable earnings/deductions
- KAPCO-style PDF salary slip, print/download and WhatsApp share
- Reports, audit log, settings and SQLite backup/restore
- Fully offline local SQLite database

## Run

```bash
flutter create --platforms android --org pk.com.kapco .
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Or push to GitHub and run the included **Build Android APK** workflow.
