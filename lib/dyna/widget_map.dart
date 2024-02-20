import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var widgetMap = {
  'Text': (params) => Text(params['posParam'][0]),
  'Column': (params) => Column(children: ParamUtils.listAs<Widget>(params['children'])),
  'Image': (params) => Image(image: params['posParam'][0]),
  'Scaffold': (params) => Scaffold(appBar: params['appBar'], body: params['body']),
  'AppBar':(params) => AppBar(title: params['title']),
  'Center':(params) => Center(child: params['child'])
};
