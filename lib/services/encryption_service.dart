import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key key;
  final IV iv;
  final Encrypter encrypter;

  EncryptionService(String base64Key)
      : key = Key.fromBase64(base64Key),
        iv = IV.fromLength(16),
        encrypter = Encrypter(AES(Key.fromBase64(base64Key), mode: AESMode.cbc));

  String encrypt(String plain) {
    final encrypted = encrypter.encrypt(plain, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  String decrypt(String cipher) {
    final data = base64Decode(cipher);
    final ivBytes = data.sublist(0, 16);
    final cipherBytes = data.sublist(16);
    return encrypter.decrypt(Encrypted(cipherBytes), iv: IV(ivBytes));
  }
}
