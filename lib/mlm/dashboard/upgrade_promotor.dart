import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:myky_clone/utils/en_extensions.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/upi_apps_service.dart';
import '../../widget/file_download_controller.dart';
import '../../widget/image_picker.dart';
import '../../widget/installed_app_list.dart';
import '../../widget/theme.dart';

class UpgradePromoter extends StatefulWidget {
  const UpgradePromoter({super.key});

  @override
  State<UpgradePromoter> createState() => _UpgradePromoterState();
}

class _UpgradePromoterState extends State<UpgradePromoter> {
  bool uploadingImage = false;
  String progressStringImage = "";
  File? _image;
  String? qrImage;

  late UPIAppService appService;
  List<Map<String, String>> installedApps = [];

  @override
  void initState() {
    // TODO: implement initState
    appService = Get.find<UPIAppService>();
    installedApps = appService.getInstalledApps();
    super.initState();
  }

  Future getQRImage() async {
    return await Api.http.get('member/terms-conditions').then((response) async {
      setState(() {
        qrImage = response.data['qrCodeImage'];
      });
      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: text('Upgrade to promoter')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    _buildPaymentDetailRow("Bank Name :", "Kerala Bank"),
                    10.heightBox,
                    _buildPaymentDetailRow("Account Name :",
                        "Luck and Belief Marketing Solutions Pvt Ltd"),
                    10.heightBox,
                    _buildPaymentDetailRow(
                        "Account Number :", "115410801200120"),
                    10.heightBox,
                    _buildPaymentDetailRow("IFSC Code :", " KSBK0001154"),
                    10.heightBox,
                    _buildUPIRow(context),
                    const SizedBox(height: 10.0),
                    buildPayButton(),
                    const SizedBox(height: 10.0),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        FileDownloadCtrl().download(
                          qrImage!,
                          context,
                        );
                      },
                      child: text('Download QR Image', fontSize: 10.0),
                    ))
                  ],
                )),
            const SizedBox(height: 30.0),
            text(
              'Payment Screenshot ',
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 10.0),
            buildStackUI(context),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  textContent: 'Submit',
                  onPressed: () async {
                    if (true) {
                      dynamic receiptImage;
                      if (_image != null) {
                        receiptImage = await Vapor.upload(
                          _image!,
                        );
                      }
                      setState(() {
                        uploadingImage = false;
                      });

                      Map sendData = {
                        'payment_proof': receiptImage,
                      };

                      Api.http
                          .post('member/promotor-request/store', data: sendData)
                          .then((res) async {
                        if (res.data['status']) {
                          Get.back();
                          AppUtils.showSuccessSnackBar(res.data['message']);
                        } else {
                          AppUtils.showErrorSnackBar(res.data['error']);
                        }
                      }).catchError((errors) {
                        if (errors.response.statusCode == 422) {
                          AppUtils.showErrorSnackBar(
                              errors.response.data['errors']['image'][0]);
                        }
                      });
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIRow(BuildContext context) {
    return Row(
      children: [
        text("UPI ID :", fontweight: FontWeight.bold, fontSize: 13.0),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText("9656703607@okbizaxis",
              style: TextStyle(
                fontSize: 13.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              )),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Theme.of(context).primaryColor),
          onPressed: () {
            Clipboard.setData(
                const ClipboardData(text: "9656703607@okbizaxis"));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("UPI ID copied to clipboard")),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Row(
      children: [
        text(label, fontweight: FontWeight.bold, fontSize: 13.0),
        const SizedBox(width: 5),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Stack buildStackUI(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          margin: const EdgeInsets.all(spacing_control),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: <Widget>[
              if (!uploadingImage)
                _image != null
                    ? Image.file(
                        _image!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: SizedBox(
                        height: 200,
                        child: Center(
                          child: text(
                            'Attach screenshot',
                          ),
                        ),
                      )),
              if (uploadingImage)
                const SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                    ],
                  ),
                )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(spacing_control),
          margin: const EdgeInsets.only(top: 15, right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: white_color,
            border: Border.all(color: colorPrimary),
          ),
          child: GestureDetector(
            onTap: () {
              GetImageFromDevice.instance
                  .getImage(ImgSource.both, context)
                  .then((file) {
                if (file != null) {
                  _image = file;
                  setState(() {});
                }
              });
            },
            child: Icon(
              Icons.camera_alt,
              color: colorPrimary,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }

  void _showUpiAppsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: installedApps.isNotEmpty
              ? InstalledAppList(installedApps: installedApps)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget buildPayButton() {
    return GestureDetector(
      onTap: () {
        // if (_nameController.text.isNotEmpty &&
        //     _mobileController.text.isNotEmpty &&
        //     _whatsappNumberController.text.isNotEmpty &&
        //     _addressController.text.isNotEmpty &&
        //     _pinCodeController.text.isNotEmpty &&
        //     _nomineeController.text.isNotEmpty) {
        //   HapticFeedback.heavyImpact(); // Adds haptic feedback
        _showUpiAppsBottomSheet();
        // _launchUPI();
        // } else {
        //   AppUtils.showErrorSnackBar(
        //       'Kindly submit the necessary details as mentioned above."');
        // }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Center(
            child: Text(
              "Pay ₹999",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ).paddingSymmetric(horizontal: 10);
  }
}
