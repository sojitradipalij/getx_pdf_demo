import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import 'home_state.dart';
import 'pdf_generator.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  HomeState? homeState;

  @override
  Widget build(BuildContext context) {
    homeState = Get.find<HomeState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Demo"),
      ),
      body: bodyView(context),
    );
  }

  Widget bodyView(BuildContext context) {
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: homeState!.saveAsFile,
        )
    ];

    return PdfPreview(
      maxPageWidth: 700,
      build: (format) => PdfGenerator.generate(
          format, homeState!.tableHeaders, homeState!.dataTable),
      actions: actions,
      canChangePageFormat: false,
      canChangeOrientation: false,
      // previewPageMargin: EdgeInsets.only(top: 10.sp,left: 10.sp,right: 10.sp),
      canDebug: false,
    );
  }
}
