import 'dart:ui';
import 'package:flutter/material.dart';

class  ColorConstant {
  static Color gray2007c = fromHex('#7ce6e9e9');

  static Color blueA200 = fromHex('#4289fa');

  static Color deepPurple600 = fromHex('#5b4ea8');

  static Color blueGray60014 = fromHex('#145f6b80');

  static Color cyan700A0 = fromHex('#a01499a1');

  static Color lightGreen = fromHex('#66C1BD');

  static Color lightText = fromHex('#838687');

  static Color darkBg = fromHex('#D7E1E1');

  static Color whiteA70099 = fromHex('#99ffffff');

  static Color cyan70078 = fromHex('#781499a1');

  static Color blueGray700 = fromHex('#403875');

  static Color gray8008c = fromHex('#8c3b3a4a');

  static Color blueGray100 = fromHex('#d9d9d9');

  static Color gray800 = fromHex('#3b3a4a');

  static Color gray2008c = fromHex('#8ce6e9e9');

  static Color gray200 = fromHex('#D7E1E1');

  static Color gray80099 = fromHex('#993b3a4a');

  static Color gray80054 = fromHex('#543b3a4a');

  static Color gray80096 = fromHex('#963b3a4a');

  static Color blueGray80014 = fromHex('#142a446e');

  static Color gray50054 = fromHex('#54a4a4ae');

  static Color bluegray400 = fromHex('#888888');

  static Color blueGray40001 = fromHex('#768295');

  static Color whiteA700 = fromHex('#ffffff');

  static Color blueGray70001 = fromHex('#403774');

  static Color gray100C4 = fromHex('#c4f6f5f6');

  static Color deepPurple500 = fromHex('#6051be');

  static Color teal200 = fromHex('#65c1bc');

  static Color gray50 = fromHex('#f8f8f8');

  static Color whiteA70070 = fromHex('#70ffffff');

  static Color blueGray20001 = fromHex('#b8ccca');

  static Color cyan7008c = fromHex('#8c1499a1');

  static Color gray80070 = fromHex('#703b3a4a');

  static Color gray10054 = fromHex('#54f6f5f6');

  static Color black900 = fromHex('#000000');

  static Color gray900A0 = fromHex('#a00d0d1b');

  static Color gray10099 = fromHex('#99f6f5f6');

  static Color blueGray70038 = fromHex('#38403774');

  static Color whiteA70038 = fromHex('#ffffff').withOpacity(0.44);

  static Color deepPurple7000c = fromHex('#0c594691');

  static Color gray8001c = fromHex('#1c3b3a4a');

  static Color gray700 = fromHex('#585151');

  static Color grayLight = fromHex('#E7EAEA');

  static Color darkWhite = fromHex('#E5EFED');

  static Color blueGreen = fromHex('#6D908F');

  static Color grayTextColor = fromHex('#7C8B88');

  static Color blueGray200 = fromHex('#bbbed1');

  static Color gray500 = fromHex('#a4a4ae');

  static Color blueGray400 = fromHex('#7f7f90');

  static Color gray900 = fromHex('#0d0d1b');

  static Color gray80038 = fromHex('#383b3a4a');

  static Color gray80078 = fromHex('#783b3a4a');

  static Color gray300 = fromHex('#D7E1E1');

  static Color gray30002 = fromHex('#dae6e5');

  static Color gray30001 = fromHex('#dadce1');

  static Color gray100 = fromHex('#f6f5f6');

  static Color gray80082 = fromHex('#823b3a4a');

  static Color teal20001 = fromHex('#7fbdba');

  static Color cyan700 = fromHex('#1499a1');

  static Color gray800A0 = fromHex('#a03b3a4a');

  static Color gray8006e = fromHex('#6e3b3a4a');
  
  static Color cardShadow = fromHex('#C5D2D2');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
