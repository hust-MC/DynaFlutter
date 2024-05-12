import 'dart:convert';

import 'package:dyna_flutter/dyna/dyna_manager.dart';
import 'package:dyna_flutter/dyna/param_resover.dart';
import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:dyna_flutter/widget/loading_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'channel/fair_message_channel.dart';
import 'dyna_utils.dart';
import 'map/widget_map.dart';

const String KEY_PATH = 'path';
const String KEY_PAGE_NAME = 'pageName';
const String PAGE_NAME = 'dynaPage';

runDyna(Widget app) async {
  print("MCLOG=== runDyna");
  var script = await rootBundle.loadString(assetsBaseJsPath);
  print("MCLOG=== runDyna script path : $assetsBaseJsPath");
  var map = <dynamic, dynamic>{};

  map[KEY_PATH] = script;
  map[KEY_PAGE_NAME] = 'loadCoreJs';

  FairMessageChannel().loadJS(jsonEncode(map), (msg) => "MCLOG=== runApp: $msg").then((value) => runApp(app));
}

class DynaWidget extends StatefulWidget {
  DynaWidget({Key? key});

  @override
  State<StatefulWidget> createState() => DynaState();
}

class DynaState extends State<DynaWidget> {
  Widget? _child;
  FairMessageChannel? _channel;

  @override
  void initState() {
    super.initState();
    _channel ??= FairMessageChannel();
    //接收setState()的信息
    _channel!.setMessageHandler((message) {
      var data = json.decode(message ?? '');
      var className = data[KEY_PAGE_NAME];
      print("MCLOG===== FairMessageChannel: data=$data; className=$className");
      // var call = _callBacks[className];
      // call?.call(message);
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _child ?? LoadingScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  init() async {
    await addScript();
    DynaManager().registerWidget(PAGE_NAME, this);
    refresh();
  }

  Future<void> refresh() async {
    String source = await getDynaSource() ?? "";
    print("MCLOG==== raw source: $source");

    var widgetTree = json.decode(source);
    _resolveWidget(widgetTree).then((value) => setState(() => {_child = value}));
  }

  Future<dynamic> addScript() async {
    var script = await getDynaJsSource();
    var map = <dynamic, dynamic>{};
    map[KEY_PATH] = script;
    map[KEY_PAGE_NAME] = PAGE_NAME;
    return _channel!.loadJS(jsonEncode(map), null);
  }

  Future<dynamic> _resolveWidget(Map source) async {
    print("MCLOG ==== source: $source");
    if (source.isEmpty) {
      return Text('Error');
    }

    var name = source['widget'];
    var paramsMap = source['params'];
    var pp = await _resolvePosParams(paramsMap['pos']);
    var np = await _resolveNameParams(paramsMap['name']);
    Object Function(Params)? widgetBlock = widgetMap[name];
    print("MCLOG ==== widgetBlock: $widgetBlock; pp: $pp; np: $np; name: $name");
    var params = ParamUtils.transform(pp, np);
    print("MCLOG ==== params: $params");
    return widgetBlock!(params);
  }

  Future<List> _resolvePosParams(dynamic params) async {
    final posParams = [];
    if (params is List) {
      for (var element in params) {
        if (element is Map) {
          posParams.add(await _resolveWidget(element));
        } else if (element is String) {
          var result = await ParamResolver.resolve(element);
          posParams.add(result ?? element);
        } else {
          posParams.add(element);
        }
      }
    }
    return posParams;
  }

  Future<Map<String, dynamic>> _resolveNameParams(dynamic params) async {
    Map<String, dynamic> nameParams = {};

    if (params is Map) {
      final children = [];

      for (var key in params.keys) {
        var child = params[key];
        if (child is List) {
          for (var element in child) {
            children.add(await _resolveWidget(element));
          }
          nameParams[key] = children;
        } else if (child is Map) {
          nameParams[key] = await _resolveWidget(child);
        } else if (child is String) {
          var result = await ParamResolver.resolve(child);
          nameParams[key] = result ?? child;
        } else {
          nameParams[key] = child;
        }
      }
    }
    return nameParams;
  }

  @override
  void dispose() {
    super.dispose();
    DynaManager().unregisterWidget(PAGE_NAME);
  }
}
