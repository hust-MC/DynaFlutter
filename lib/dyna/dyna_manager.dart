import 'package:dyna_flutter/dyna/dyna_widget.dart';

class DynaManager {

  static const String METHOD = 'method';
  static const String VARIABLE = 'variable';
  static const String ALL_BIND_DATA = 'getAllBindData';
  static const String EVALUATE = 'evaluate';
  static const String FUNC_NAME = 'funcName';
  static const String ARGS = 'args';
  static const String LOAD_JS = 'loadJsFile';
  static const String RELEASE_JS = 'releaseJS';
  static const String PATH = 'path';
  static const String PAGE_NAME = 'pageName';

  static final DynaManager _instance = DynaManager._internal();

  DynaManager._internal();

  factory DynaManager() {
    return _instance;
  }


  static final Map<String, DynaState> _stateList = <String, DynaState>{};

  void registerWidget(String widgetName, DynaState state) {
    _stateList[widgetName] = state;
  }

  void unregisterWidget(String widgetName) {
    _stateList.remove(widgetName);
  }

  DynaState? getState(String widgetName) => _stateList[widgetName];
}