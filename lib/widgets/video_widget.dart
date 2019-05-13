import 'package:iot_ui/widgets/pending_action.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoWidget extends StatefulWidget {
  final String url;

  VideoWidget({@required this.url});
  @override
  _VideoWidgetState createState() => _VideoWidgetState(url);
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  String url;

  _VideoWidgetState(this.url);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : PendingAction(),
        Container(
          width: 30,
          height: 30,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
