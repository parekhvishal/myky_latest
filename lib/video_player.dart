import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    _controller = YoutubePlayerController(
      initialVideoId: Get.arguments,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
    _controller.toggleFullScreenMode();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeRight,
  //     DeviceOrientation.landscapeLeft,
  //   ]);
  //   videoId = Get.arguments;
  //   controller = YoutubePlayerController(
  //     initialVideoId: videoId,
  //     flags: const YoutubePlayerFlags(
  //       autoPlay: true,
  //     ),
  //   );
  //   // controller!.toggleFullScreenMode();
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        Get.back();
        return Future.value(false);
      },
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          key: ObjectKey(_controller),
          controller: _controller,
          actionsPadding: const EdgeInsets.only(left: 16.0),
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () {
                // log('Settings Tapped!');
              },
            ),
          ],
          bottomActions: [
            CurrentPosition(),
            const SizedBox(width: 10.0),
            ProgressBar(isExpanded: true),
            const SizedBox(width: 10.0),
            RemainingDuration(),
            InkWell(
              child: FullScreenButton(),
              onTap: () {},
            ),
          ],
        ),
        builder: (context, player) => Scaffold(
          body: player,
        ),
      ),
    );
  }

// @override
// dispose() {
//   controller!.dispose();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeRight,
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   super.dispose();
// }
}
