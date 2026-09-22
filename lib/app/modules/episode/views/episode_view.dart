import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/episode_controller.dart';

class EpisodeView extends GetView<EpisodeController> {
  const EpisodeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('episodeview'.tr), centerTitle: true),
      body: const Center(
        child: Text('EpisodeView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
