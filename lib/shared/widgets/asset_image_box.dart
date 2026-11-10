import 'package:flutter/material.dart';

class AssetImageBox extends StatelessWidget {
  const AssetImageBox({super.key, required this.path, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFBFD9A0),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 40, color: Colors.white),
      ),
    );
  }
}