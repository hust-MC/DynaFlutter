
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class ForInStatementNode extends StatementNode {
  String? loopVariable;
  GenericStatementNode? iterable;
  String? body;

  @override
  String toSource() {
    return '''
    for (let $loopVariable in ${iterable?.toSource()}) {
      $body
    }
    ''';
  }
}
