import 'dart:convert';

import 'package:dyna_flutter/dyna/param_resover.dart';
import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:dyna_flutter/widget/loading_screen.dart';
import 'package:flutter/widgets.dart';
import 'dyna_utils.dart';
import 'map/widget_map.dart';

class DynaWidget extends StatefulWidget {
  DynaWidget({Key? key});

  @override
  State<StatefulWidget> createState() => DynaState();
}

class DynaState extends State<DynaWidget> {
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    print("MCLOG ==== build");
    return _child ?? LoadingScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveResource().then((value) {
      setState(() => {_child = value});
    });
  }

  Future<Widget?> _resolveResource() async {
    String source = await getDynaSource() ?? "";
    print("MCLOG==== raw source: $source");

    var widgetTree = json.decode(source);
    return _resolveWidget(widgetTree);
  }

  dynamic _resolveWidget(Map source) {
    print("MCLOG ==== source: $source");
    if (source.isEmpty) {
      return Text('Error');
    }

    var name = source['widget'];
    var paramsMap = source['params'];
    var pp = _resolvePosParams(paramsMap['pos']);
    var np = _resolveNameParams(paramsMap['name']);
    Object Function(Params)? widgetBlock = widgetMap[name];
    print("MCLOG ==== widgetBlock: $widgetBlock; pp: $pp; np: $np; name: $name");
    var params = ParamUtils.transform(pp, np);
    print("MCLOG ==== params: $params");
    return widgetBlock!(params);
  }

  List _resolvePosParams(dynamic params) {
    final posParams = [];
    if (params is List) {
      params.forEach((element) {
        if (element is Map) {
          posParams.add(_resolveWidget(element));
        } else {
          posParams.add(element);
        }
      });
    }
    return posParams;
  }

  Map<String, dynamic> _resolveNameParams(dynamic params) {
    Map<String, dynamic> nameParams = {};

    if (params is Map) {
      final children = [];
      params.forEach((key, child) {
        if (child is List) {
          for (var element in child) {
            children.add(_resolveWidget(element));
          }
          nameParams[key] = children;
        } else if (child is Map) {
          nameParams[key] = _resolveWidget(child);
        } else if (child is String) {
          var result = ParamResolver.resolve(child);
          nameParams[key] = result ?? child;
        } else {
          nameParams[key] = child;
        }
      });
    }
    return nameParams;
  }
}

dynamic _resolveEscape(String paramString) {

}