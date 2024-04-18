
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class SwitchStatementNode extends StatementNode {
  GenericStatementNode? expr;
  List<List<String>>? cases;
  String? default_;

  String genCase(List<String> case_) {
    return case_.length == 2
        ? '''
    case ${case_[0]}:
    ${case_[1]}
    '''
        : '''
    case ${case_[0]}:
    ''';
  }

  String genDefault() {
    return default_ != null && default_!.isNotEmpty
        ? '''
    default:
      $default_
    '''
        : '';
  }

  @override
  String toSource() {
    return '''
    switch (${expr?.toSource()}) {
      ${cases != null && cases!.isNotEmpty ? cases?.map((e) => genCase(e)).join('') : ''}
      ${genDefault()}
    }
    ''';
  }
}