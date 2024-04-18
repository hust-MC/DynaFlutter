
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import '../generator/helper.dart';

class AwaitStatementNode extends StatementNode {
  StatementNode? expr;

  @override
  String toSource() {
    return '''await ${addCommaAsNeeded(expr?.toSource())}''';
  }
}