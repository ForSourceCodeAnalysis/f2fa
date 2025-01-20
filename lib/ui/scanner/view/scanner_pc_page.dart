import 'package:f2fa/generated/generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class ScannerPcPage extends StatelessWidget {
  const ScannerPcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.sppScan.tr()),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();

            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );

            if (image == null) {
              return;
            }
            Code resultFromXFile = await zx.readBarcodeImagePath(
              image,
              DecodeParams(
                format: Format.qrCode,
                imageFormat: ImageFormat.rgb,
              ),
            );
            if (context.mounted) {
              Navigator.of(context).pop(resultFromXFile.text);
            }
          },
          child: Text(LocaleKeys.sppSelectImage.tr()),
        ),
      ),
    );
  }
}
