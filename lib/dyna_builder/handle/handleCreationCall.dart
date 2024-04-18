// import 'package:analyzer/dart/ast/ast.dart';
//
//
// NewOperatorStatementNode handleCreationCall( InstanceCreationExpression currentNode) {
//   var gnNode = NewOperatorStatementNode();
//   gnNode.methodName = currentNode.constructorName.toString();
//   currentNode.argumentList.arguments.forEach((arg) {
//     if (arg is NamedExpression) {
//       gnNode.namedParameters.add([
//         arg.name.label.toString(),
//         convertExpression(arg.expression.toString())
//       ]);
//     } else {
//       gnNode.unnamedParameters.add(convertExpression(arg.toString()));
//     }
//   });
//   return gnNode;
// }