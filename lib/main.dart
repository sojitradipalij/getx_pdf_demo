import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getx_pdf_demo/ui/HomeScreen/home_binding.dart';

import 'ui/HomeScreen/home_screen.dart';
import 'utils/app_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: () => GetMaterialApp(
              title: 'PDF Demo',
              initialBinding: HomeBinding(),
              debugShowCheckedModeBanner: false,
              builder: (context, widget) {
                //add this line
                ScreenUtil.setContext(context);
                return MediaQuery(
                  //Setting font does not change with system font size
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!,
                );
              },
              theme: ThemeData(
                primarySwatch: primaryMaterialColor,
              ),
              home: HomeScreen(),
            ));
  }
}
