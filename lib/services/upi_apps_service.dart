// app_service.dart

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:get/get.dart';

class UPIAppService extends GetxService {
  // Regular list for installed apps
  List<Map<String, String>> installedAppPackages = [];

  // List of payment apps to check
  final List<Map<String, String>> paymentAppPackages = [
    {
      "packageName": "money.super.payments",
      "appName": "Super.money",
      "appIcon": 'assets/paymentAppIcon/supermoney.jpeg',
    },
    {
      "packageName": "com.google.android.apps.nbu.paisa.user",
      "appName": "GPay",
      "appIcon": 'assets/paymentAppIcon/gpay.jpeg',
    },
    {
      "packageName": "com.phonepe.app",
      "appName": "PhonePe",
      "appIcon": 'assets/paymentAppIcon/phonepe.jpg',
    },
    {
      "packageName": "net.one97.paytm",
      "appName": "Paytm",
      "appIcon": 'assets/paymentAppIcon/paytm.jpg',
    },
    {
      "packageName": "com.mobikwik_new",
      "appName": "MobiKwik",
      "appIcon": 'assets/paymentAppIcon/mobikwik.jpeg',
    },
    {
      "packageName": "com.dreamplug.androidapp",
      "appName": "CRED",
      "appIcon": 'assets/paymentAppIcon/cred.jpg',
    },
    {
      "packageName": "in.org.npci.upiapp",
      "appName": "BHIM",
      "appIcon": 'assets/paymentAppIcon/bhimUPI.jpg',
    },
    {
      "packageName": "com.hdfcbank.payzapp",
      "appName": "PAYZAPP",
      "appIcon": 'assets/paymentAppIcon/payzapp.jpg',
    },
    {
      "packageName": "com.csam.icici.bank.imobile",
      "appName": "ICICI",
      "appIcon": 'assets/paymentAppIcon/icici.jpg',
    },
    {
      "packageName": "com.axis.mobile",
      "appName": "Axis Pay",
      "appIcon": 'assets/paymentAppIcon/axisbank.jpg',
    },
    {
      "packageName": "com.myairtelapp",
      "appName": "Airtel Thanks",
      "appIcon": 'assets/paymentAppIcon/airtel.jpg',
    },
    {
      "packageName": "com.freecharge.android",
      "appName": "FreeCharge",
      "appIcon": 'assets/paymentAppIcon/freecharge.jpg',
    },
    {
      "packageName": "com.bharatpe.app",
      "appName": "BharatPe",
      "appIcon": 'assets/paymentAppIcon/bharatpe.jpg',
    },
    {
      "packageName": "com.sbi.upi",
      "appName": "BHIM SBI",
      "appIcon": 'assets/paymentAppIcon/sbibhim.jpg',
    },
    {
      "packageName": "com.jio.myjio",
      "appName": "Jio Pay",
      "appIcon": 'assets/paymentAppIcon/jiopay.jpg',
    },
    {
      "packageName":
          "com.kotak811mobilebankingapp.instantsavingsupiscanandpayrecharge",
      "appName": "Kotak",
      "appIcon": 'assets/paymentAppIcon/kotak.jpg',
    },
    {
      "packageName": "com.icicibank.pockets",
      "appName": "Pockets ICICI",
      "appIcon": 'assets/paymentAppIcon/pockets.jpg',
    },
  ];

  // Initialize the service and check installed apps
  Future<UPIAppService> init() async {
    await checkInstalledApps();
    return this;
  }

  // Method to check installed apps
  Future<void> checkInstalledApps() async {
    installedAppPackages.clear(); // Clear the list to avoid duplicate entries

    for (var app in paymentAppPackages) {
      bool isAppInstalled = await LaunchApp.isAppInstalled(
        androidPackageName: app["packageName"]!,
      );

      if (isAppInstalled) {
        installedAppPackages.add(app);
      }
    }
  }

  // Getter to access installed apps
  List<Map<String, String>> getInstalledApps() {
    return installedAppPackages;
  }
}
