import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

class IntroductoryVideo extends StatefulWidget {
  const IntroductoryVideo({Key? key}) : super(key: key);

  @override
  _IntroductoryVideoState createState() => _IntroductoryVideoState();
}

class _IntroductoryVideoState extends State<IntroductoryVideo> {
  GlobalKey<PaginatedListState> paginatedKey = GlobalKey();
  List? videos;

  @override
  void initState() {
    fetchVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Self Introductory Video'),
      ),
      body: (videos != null)
          ? Container(
              child: Wrap(
              children: List.generate(videos!.length, (index) => _buildItem(videos![index])),
            ))
          : Container(),
    );
  }

  Widget _buildItem(item) {
    return Container(
      height: h(22),
      margin: EdgeInsets.only(
        bottom: 8,
      ),
      child: Stack(
        children: [
          PNetworkImage(
            youTubeThumbnail(item['link'].toString().split('/').last),
            width: w(100),
            height: h(22),
            fit: BoxFit.fill,
          ).opacity(opacity: 0.7),
          Center(
            child: new ClipRect(
              child: new BackdropFilter(
                filter: new ImageFilter.blur(
                  sigmaX: 0.5,
                  sigmaY: 0.5,
                ),
                child: new Container(
                  height: h(22),
                  width: w(100),
                  decoration: new BoxDecoration(color: Colors.black.withOpacity(0.35)),
                  child: Center(
                      child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // border: Border.all(
                      //   color: whiteColor.withOpacity(0.5),
                      //   width: 2.5,
                      // ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        UniconsLine.youtube,
                        color: red,
                        size: s(20),
                      ),
                    ),
                  )),
                ),
              ),
            ),
          )
        ],
      ),
    ).onTap(() {
      Get.toNamed('/video-player', arguments: item['link'].toString().split('/').last);
    });
  }

  String youTubeThumbnail(id) {
    return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  void fetchVideos() {
    Api.http.get('member/introductory-video').then((response) {
      if (response.data['status']) {
        setState(() {
          videos = response.data['list'];
        });
      }
    });
  }
}
