class StatementNode {
  String toSource() {
    return '';
  }

  @override
  String toString() {
    return toSource();
  }
}

class GenericStatementNode extends StatementNode {
  String? code;

  GenericStatementNode(String code_) {
    code = code_;
  }

  @override
  String toSource() {
    return code ?? '';
  }
}