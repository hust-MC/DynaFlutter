import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 背景遮罩
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Loading指示器
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}