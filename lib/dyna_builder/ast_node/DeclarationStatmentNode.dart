
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class DeclarationStatmentNode extends StatementNode {
  List<String> variables = [];

  @override
  String toSource() {
    return '''
      let ${variables.join(',')};
    ''';
  }
}