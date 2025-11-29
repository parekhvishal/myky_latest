import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

class ViewReturnOrder extends StatefulWidget {
  const ViewReturnOrder({Key? key}) : super(key: key);

  @override
  State<ViewReturnOrder> createState() => _ViewReturnOrderState();
}

class _ViewReturnOrderState extends State<ViewReturnOrder> {
  Map? orderData;
  late VideoPlayerController _controller;

  @override
  void initState() {
    orderData = Get.arguments;
    if (orderData!['returnDetails']['returnProductVideo'] != null) {
      _controller = VideoPlayerController.network(orderData!['returnDetails']['returnProductVideo'])
        ..initialize().then((_) {
          // _controller.play();
          // Ensure the first frame is shown after the video is initialized
          setState(() {});
        });
      ;
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Return Order View'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text('${orderData!['subOrderNo']}'),
              20.height,
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  text(
                    'Return Type : ',
                    fontSize: 13.0,
                    fontFamily: fontBold,
                    fontweight: FontWeight.w600,
                  ),
                  Flexible(
                    child: text(
                      '${orderData!['returnDetails']['reason']}',
                      fontSize: 13.0,
                      isLongText: true,
                    ),
                  ),
                ],
              ),
              if (orderData!['returnRejectReason'] != null)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    text(
                      'Reject Reason : ',
                      fontSize: 13.0,
                      fontFamily: fontBold,
                      fontweight: FontWeight.w600,
                    ),
                    Flexible(
                      child: text(
                        '${orderData!['returnRejectReason']}',
                        fontSize: 13.0,
                        isLongText: true,
                      ),
                    ),
                  ],
                ),
              10.height,
              text('Uploaded Images :'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PNetworkImage(
                    orderData!['returnDetails']['returnProductImage1'],
                    width: 150,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  PNetworkImage(
                    orderData!['returnDetails']['returnProductImage2'],
                    width: 150,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              if (orderData!['returnDetails']['returnProductVideo'] != null) ...[
                10.height,
                AspectRatio(
                  aspectRatio: 13 / 10,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(
                        _controller,
                      ),
                      // Play/Pause Buttons
                      _controller.value.isPlaying
                          ? SizedBox.shrink()
                          : IconButton(
                              icon: Icon(Icons.play_arrow),
                              iconSize: 64,
                              onPressed: () {
                                setState(() {
                                  _controller.play();
                                });
                              },
                            ),

                      _controller.value.isPlaying
                          ? SizedBox.shrink()
                          : Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.play();
                                  });
                                },
                              ),
                            ),
                      _controller.value.isPlaying
                          ? SizedBox.shrink()
                          : Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  iconSize: 64,
                                  onPressed: () {
                                    setState(() {
                                      _controller.play();
                                    });
                                  },
                                ),
                              ),
                            ),
                      _controller.value.isPlaying
                          ? Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.pause),
                                onPressed: () {
                                  setState(() {
                                    _controller.pause();
                                  });
                                },
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
