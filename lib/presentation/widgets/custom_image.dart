import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImage extends StatelessWidget {
  final double height;
  final double? width;
  final String imageUrl;
  final BoxFit fit;
  const CustomImage({super.key, required this.height, this.width, required this.imageUrl, this.fit = BoxFit.fill});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width, child: imageUrl.endsWith(".svg") ? SvgPicture.asset(imageUrl, fit: fit) : Image(image: AssetImage(imageUrl), fit: fit));
  }
}
