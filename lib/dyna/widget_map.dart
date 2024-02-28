import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var widgetMap = {
  'Text': (Params params) => Text(params.posParam[0]),
  'Column': (Params params) =>
      Column(children: ParamUtils.listAs<Widget>(params.nameParam['children'])),
  'Image': (Params params) => Image(image: params.posParam[0]),
  'Scaffold': (Params params) =>
      Scaffold(appBar: params.nameParam['appBar'], body: params.nameParam['body']),
  'AppBar': (Params params) => AppBar(title: params.nameParam['title']),
  'Center': (Params params) => Center(child: params.nameParam['child'])
};

class Params {
  var nameParam = {};
  var posParam = [];
}
