import 'package:get/get.dart';

import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';
import '../modules/episode/bindings/episode_binding.dart';
import '../modules/episode/views/episode_view.dart';
import '../modules/episode_player/bindings/episode_player_binding.dart';
import '../modules/episode_player/views/episode_player_view.dart';
import '../modules/help_center/bindings/help_center_binding.dart';
import '../modules/help_center/views/help_center_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/mix/bindings/mix_binding.dart';
import '../modules/mix/views/mix_view.dart';
import '../modules/movie/bindings/movie_binding.dart';
import '../modules/movie/views/movie_view.dart';
import '../modules/navbar/bindings/navbar_binding.dart';
import '../modules/navbar/views/navbar_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/notifications/views/widgets/notification_detail_view.dart';
import '../modules/player/bindings/player_binding.dart';
import '../modules/player/views/player_view.dart';
import '../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/privacy_policy/views/privacy_policy_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/term_of_use/bindings/term_of_use_binding.dart';
import '../modules/term_of_use/views/term_of_use_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.NAVBAR,
      page: () => NavbarView(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    // GetPage(
    //   name: _Paths.SHORT,
    //   page: () => ShortView(),
    //   binding: ShortBinding(),
    // ),
    GetPage(
      name: _Paths.ACCOUNT,
      page: () => AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.EPISODE_PLAYER,
      page: () => EpisodeOverlay(),
      binding: EpisodePlayerBinding(),
      transition: Transition.noTransition,
    ),
    // GetPage(
    //   name: _Paths.MOVIE_BANNER,
    //   page: () => MovieBannerView(),
    //   binding: MovieBannerBinding(),
    // ),
    GetPage(
      name: _Paths.MIX,
      page: () => const MixView(),
      binding: MixBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // GetPage(
    //   name: _Paths.MOVIE_DETAIL,
    //   page: () => const MovieDetailView(),
    //   binding: MovieDetailBinding(),
    // ),
    GetPage(
      name: _Paths.MOVIE,
      page: () => const MovieView(),
      binding: MovieBinding(),
    ),
    GetPage(
      name: _Paths.EPISODE,
      page: () => const EpisodeView(),
      binding: EpisodeBinding(),
    ),
    GetPage(
      name: _Paths.PLAYER,
      page: () => const PlayerView(),
      binding: PlayerBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: '/privacy-policy',
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.TERM_OF_USE,
      page: () => const TermOfUseView(),
      binding: TermOfUseBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.HELP_CENTER,
      page: () => const HelpCenterView(),
      binding: HelpCenterBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: '/notifications/:id',
      page: () => const NotificationDetailView(),
      binding: NotificationsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
