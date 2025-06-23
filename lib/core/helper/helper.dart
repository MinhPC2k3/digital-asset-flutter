String shortenMiddleResponsive(String text, double screenWidth) {
  // Adjust these thresholds as needed
  int head, tail;

  if (screenWidth < 300) {
    head = 3;
    tail = 2;
  } else if (screenWidth < 500) {
    head = 6;
    tail = 4;
  } else {
    head = 10;
    tail = 6;
  }

  if (text.length <= head + tail + 3) return text;
  return '${text.substring(0, head)}...${text.substring(text.length - tail)}';
}

BigInt covertStringToBigInt(String hexString) {
  if (hexString.startsWith("0x")) {
    hexString = hexString.substring(2);
  }

  BigInt value = BigInt.parse(hexString, radix: 16);
  return value;
}