
import '../generator/const.dart';
import 'MemberAccessStatementNode.dart';

class PropertyAccessStatementNode extends MemberAccessStatementNode {
  String? fieldName;
  String? setVal;

  @override
  String toSource() {
    var finalThiz =
    thiz != null && thiz!.trim() == superSubstitution ? 'this' : thiz;
    return '''
    ${finalThiz?.isNotEmpty == true ? finalThiz! + '.' : ''}$fieldName${setVal == null ? '' : '=' + setVal! + ';'}
    ''';
  }
}
