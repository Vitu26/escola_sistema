// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class YoutubeVideoPlayerPage extends StatefulWidget {
//   final String youtubeVideoId;
//   final Function(bool) onFullScreenChanged;

//   YoutubeVideoPlayerPage({
//     required this.youtubeVideoId,
//     required this.onFullScreenChanged,
//   });

//   @override
//   _YoutubeVideoPlayerPageState createState() => _YoutubeVideoPlayerPageState();
// }

// class _YoutubeVideoPlayerPageState extends State<YoutubeVideoPlayerPage> {
//   late YoutubePlayerController _youtubeController;

//   @override
//   void initState() {
//     super.initState();
//     _youtubeController = YoutubePlayerController(
//       initialVideoId: widget.youtubeVideoId,
//       flags: YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _youtubeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerBuilder(
//       player: YoutubePlayer(
//         controller: _youtubeController,
//         showVideoProgressIndicator: true,
//       ),
//       builder: (context, player) {
//         return Scaffold(
//           body: player,
//         );
//       },
//     );
//   }
// }
