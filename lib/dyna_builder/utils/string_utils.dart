int fromHex(String hex) {
  hex = hex.replaceFirst('0x', '');
  return int.parse(hex, radix: 16);
}