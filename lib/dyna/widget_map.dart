import 'package:flutter/cupertino.dart';

var widgetMap = {
  'Text': (params) => Text(params['posParams'][0]),
  'Image': (params) => Image(image: params['posParams'][0])
};
