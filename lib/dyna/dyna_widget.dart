import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'widget_map.dart';

class DynaWidget extends StatefulWidget {
  String src;

  DynaWidget({Key? key, required this.src});

  @override
  State<StatefulWidget> createState() => DynaState();
}

class DynaState extends State<DynaWidget> {
  @override
  Widget build(BuildContext context) {
    print("MCLOG ==== build");
    return Text("CMMCMC]");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveResource();
  }

  Future<void> _resolveResource() async {
    String source = await rootBundle.loadString(widget.src);
    print("MCLOG ==== source: $source");
    var widgetTree = json.decode(source);
    print("MCLOG ==== widgetTree: $widgetTree");
    var widgetJson = widgetTree['widget'];
    if (widgetJson is Map) {
      var name = widgetJson['name'];
      var pp = widgetJson['posParam'];
      var np = widgetJson['nameParam'];
      var widgetBlock = widgetMap[name];
      print("MCLOG ==== widgetBlock: $widgetBlock");

    }
  }
}
