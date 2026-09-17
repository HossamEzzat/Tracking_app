import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracking_app/core/theme/app_color.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String description;
  const CustomAppBar({super.key, required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_ios),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style: TextStyle(fontSize: 20.sp,color: context.colors.black[100]),),
              SizedBox(height: 5.h,),
               Text(description,style: TextStyle(fontSize: 14.sp,color: context.colors.black[50]),),
            ],
          ),
      
        ),
      ),
    );
  }
}