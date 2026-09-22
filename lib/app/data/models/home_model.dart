import 'package:dmn_play/app/data/models/banner_model.dart';
import 'package:dmn_play/app/data/models/category_model.dart';
import 'package:dmn_play/app/data/models/movie_model.dart';
import 'package:dmn_play/app/data/models/subscription_model.dart';

import 'active_subscription_model.dart';

class HomeModel {
  final List<BannerModel> banner;
  final List<MovieModel> latest;
  final List<MovieModel> trending;
  final List<MovieModel> recommended;
  final List<CategoryModel> genres;
  final List<SubscriptionModel> subscriptions;
  ActiveSubscriptionModel? activeSubscription;

  HomeModel({
    required this.banner,
    required this.latest,
    required this.trending,
    required this.recommended,
    required this.genres,
    required this.subscriptions,
    required this.activeSubscription,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      banner:
          (json["banner"] as List? ?? [])
              .map((e) => BannerModel.fromJson(e))
              .toList(),

      latest:
          (json["latest"] as List? ?? [])
              .map((e) => MovieModel.fromJson(e))
              .toList(),

      trending:
          (json["trending"] as List? ?? [])
              .map((e) => MovieModel.fromJson(e))
              .toList(),

      recommended:
          (json["recommended"] as List? ?? [])
              .map((e) => MovieModel.fromJson(e))
              .toList(),

      genres:
          (json["genres"] as List? ?? [])
              .map((e) => CategoryModel.fromJson(e))
              .toList(),
      subscriptions:
          (json["subscriptions"] as List? ?? [])
              .map((e) => SubscriptionModel.fromJson(e))
              .toList(),
      activeSubscription:
          json['active_subscription'] == null
              ? null
              : ActiveSubscriptionModel.fromJson(json['active_subscription']),
    );
  }
}
