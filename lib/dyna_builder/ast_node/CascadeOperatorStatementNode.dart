
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import 'MemberAccessStatementNode.dart';

class CascadeOperatorStatementNode extends StatementNode {
  String? target;
  List<MemberAccessStatementNode>? cascades;

  @override
  String toSource() {
    var tempThiz = '__target__';
    cascades?.forEach((element) {
      element.thiz = tempThiz;
    });
    return '''(function() {
      let $tempThiz = $target;
      ${cascades?.map((e) => e.toSource()).join('')}
      return $tempThiz;
    })()
    ''';
  }
}