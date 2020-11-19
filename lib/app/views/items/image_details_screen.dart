import 'package:airscaper/common/colors.dart';
import 'package:airscaper/app/views/common/ars_scaffold.dart';
import 'package:airscaper/app/views/navigation/navigation_methods.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class ImageDetailsScreen extends StatelessWidget {

  static const imageTag = "imageTag";

  final String assetPath;
  final String title;

  const ImageDetailsScreen({Key key, this.title, this.assetPath})
      : super(key: key);

  static Route<dynamic> createRoute(String title, String assetPath) {
    return createFadeRoute(
        ImageDetailsScreen(title: title, assetPath: assetPath), "");
  }

  @override
  Widget build(BuildContext context) {
    return ARSScaffold(
      title: title,
      child: Container(
        color: arsBackgroundColor,
        constraints: BoxConstraints.expand(
          height: MediaQuery
              .of(context)
              .size
              .height,
        ),
        child: PhotoView(
          imageProvider: AssetImage(assetPath),
          heroAttributes: const PhotoViewHeroAttributes(tag: imageTag),
        ),
      ),
    );
  }
}