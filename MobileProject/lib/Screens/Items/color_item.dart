import 'package:flutter/material.dart';

hexaStringToColor(String hexaColor){
  hexaColor=hexaColor.toUpperCase().replaceAll("#", "");
  if(hexaColor.length==6){
    hexaColor="FF"+hexaColor;
  }
  return Color(int.parse(hexaColor,radix: 16));
}