import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../dyna_builder/utils/string_utils.dart';

var widgetMap = {
  'Text': (Params params) => Text(params.posParam[0]),
  'Column': (Params params) =>
      Column(children: ParamUtils.listAs<Widget>(params.nameParam['children'])),
  'Image': (Params params) => Image(image: params.posParam[0]),
  'Scaffold': (Params params) =>
      Scaffold(appBar: params.nameParam['appBar'], body: params.nameParam['body'], floatingActionButton: params.nameParam['floatingActionButton']),
  'AppBar': (Params params) => AppBar(title: params.nameParam['title']),
  'Center': (Params params) => Center(child: params.nameParam['child']),
  '`FloatingActionButton`': (Params params) => FloatingActionButton(onPressed: () {  }, child: params.nameParam['child']),
  'Icon': (Params params) => Icon(params.posParam[0]),
  'IconData':(Params params)  {
   var data = IconData(fromHex(params.posParam[0]), fontFamily: params.nameParam['fontFamily']);
  return data;
  }
};

class Params {
  var nameParam = {};
  var posParam = [];
}
