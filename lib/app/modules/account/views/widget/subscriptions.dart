import 'package:dmn_play/app/data/helpers/app_colors.dart';
import 'package:dmn_play/app/data/models/active_subscription_model.dart';
import 'package:dmn_play/app/modules/account/controllers/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helpers/currency_locale.dart';
import '../../../../data/helpers/currency_service.dart';
import '../../../../data/models/subscription_model.dart';
import '../../../../data/translations/controller/language_controller.dart';
import '../../../home/controllers/home_controller.dart';

class SubscriptionPrice extends StatelessWidget {
  final ActiveSubscriptionModel? activeSubscription;

  SubscriptionPrice({super.key, this.activeSubscription});

  final subC = Get.find<AccountController>();
  final homeC = Get.find<HomeController>();
  final currencyC = Get.find<CurrencyService>();
  final languageC = Get.find<LanguageController>();

  String formatPrice(double value) {
    final languageCode = languageC.currentLanguageCode;

    final currency = CurrencyLocale.getCurrency(languageCode);

    return currencyC.format(value, currency: currency, locale: languageCode);
  }

  int discountPercent(SubscriptionModel subscription) {
    if (!subscription.isPromo ||
        subscription.promoPrice == null ||
        subscription.price <= 0) {
      return 0;
    }

    return ((subscription.price - subscription.promoPrice!) /
            subscription.price *
            100)
        .round();
  }

  String _formatPromoEndsAt(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return '';
    }

    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subscriptions = homeC.home.value?.subscriptions ?? [];

      languageC.currentLanguageCode;
      currencyC.currentCurrency.value;
      currencyC.exchangeRate.value;

      return Scaffold(
        backgroundColor: const Color(0xFF080808),

        // ============================================================
        // APP BAR
        // ============================================================
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          surfaceTintColor: Colors.transparent,
          elevation: 0,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          title: Text(
            'subscription'.tr.capitalize ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          centerTitle: false,
        ),

        // ============================================================
        // BODY
        // ============================================================
        body:
            subscriptions.isEmpty
                ? Center(
                  child: Text(
                    'no packages available'.tr.capitalizeFirst ?? '',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                )
                : SafeArea(
                  child: RefreshIndicator(
                    color: AppColors.contentColorYellow,
                    backgroundColor: const Color(0xFF181818),

                    onRefresh: () async {
                      await subC.refreshSubscription();
                    },

                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        // ==================================================
                        // CURRENT PACKAGE
                        // ==================================================
                        const SizedBox(height: 28),
                        _buildCurrentSubscriptionStatus(activeSubscription),
                        const SizedBox(height: 28),
                        // ==================================================
                        // HEADER
                        // ==================================================
                        Text(
                          'select a package'.tr.capitalizeFirst ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'enjoy all premium content and unlimited access'
                                  .tr
                                  .capitalizeFirst ??
                              '',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // SUBSCRIPTION LIST
                        // ==================================================
                        _buildPackageTabs(subscriptions),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 470,
                          child: PageView.builder(
                            controller: subC.pageController,
                            itemCount: subscriptions.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: subC.onPageChanged,
                            itemBuilder: (context, index) {
                              return _buildSubscriptionCard(
                                subscriptions[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      );
    });
  }

  // ================================================================
  // SUBSCRIPTION CARD
  // ================================================================

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    final discount = discountPercent(subscription);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 98),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color:
              subscription.isPromo
                  ? Colors.white.withValues(alpha: .18)
                  : Colors.white.withValues(alpha: .08),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // PLAN HEADER
            // ========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VIP ICON
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.contentColorYellow,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                // PLAN NAME
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name.tr.capitalize ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.contentColorYellow,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subscription.durationText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // PROMO BADGE
                if (subscription.isPromo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.contentColorYellow.withValues(
                        alpha: .15,
                      ),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.contentColorYellow.withValues(
                          alpha: .25,
                        ),
                      ),
                    ),
                    child: Text(
                      '${'save'.tr.toUpperCase()} $discount%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.contentColorYellow,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ========================================================
            // PRICE
            // ========================================================
            if (subscription.isPromo && subscription.promoPrice != null)
              _buildPromoPrice(subscription)
            else
              _buildNormalPrice(subscription),

            const SizedBox(height: 22),

            // ========================================================
            // BENEFITS
            // ========================================================
            _BenefitItem(
              icon: Icons.play_circle_outline_rounded,
              text: 'Access all VIP content',
            ),

            const SizedBox(height: 9),

            _BenefitItem(icon: Icons.hd_rounded, text: 'Premium video quality'),

            const SizedBox(height: 9),

            _BenefitItem(icon: Icons.block_rounded, text: 'Unlimited viewing'),

            const SizedBox(height: 22),

            // ========================================================
            // BUTTON
            // ========================================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: proses subscribe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contentColorYellow,
                  foregroundColor: Colors.black,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 19),

                    SizedBox(width: 8),

                    Text(
                      'subscribe'.tr.capitalizeFirst ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================== // CURRENT SUBSCRIPTION STATUS // ===============================

  Widget _buildCurrentSubscriptionStatus(
    ActiveSubscriptionModel? subscription,
  ) {
    // ================================================================
    // FREE MEMBER
    // ================================================================

    if (subscription == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white54,
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'paket saat ini'.tr.capitalize ?? '',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Free Member'.tr.capitalize ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Upgrade untuk menikmati konten VIP'.tr,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'free'.tr.toUpperCase(),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ================================================================
    // VIP MEMBER
    // ================================================================

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.contentColorYellow.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.contentColorYellow.withValues(alpha: .25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.contentColorYellow.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.contentColorYellow,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current package'.tr,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subscription.name.capitalize ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.contentColorYellow,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.contentColorYellow,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'VIP'.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ==========================================================
          // PRICE
          // ==========================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(subscription.amount),
                style: const TextStyle(
                  color: AppColors.contentColorYellow,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(width: 6),

              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'paid'.tr,
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ==========================================================
          // DETAILS
          // ==========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .20),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                _SubscriptionInfoRow(
                  icon: Icons.schedule_rounded,
                  title: 'duration',
                  value: subscription.durationText,
                ),

                const SizedBox(height: 10),

                _SubscriptionInfoRow(
                  icon: Icons.play_circle_outline_rounded,
                  title: 'start',
                  value: _formatDate(subscription.startedAt),
                ),

                const SizedBox(height: 10),

                _SubscriptionInfoRow(
                  icon: Icons.event_rounded,
                  title: 'valid until',
                  value: _formatDate(subscription.expiresAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // ================================================================
  // NORMAL PRICE
  // ================================================================

  Widget _buildNormalPrice(SubscriptionModel subscription) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatPrice(subscription.price),
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.contentColorYellow,
            height: 1,
            letterSpacing: -.8,
          ),
        ),

        const SizedBox(width: 7),

        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            '/ ${subscription.durationText}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.contentColorYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PROMO PRICE
  // ================================================================

  Widget _buildPromoPrice(SubscriptionModel subscription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORIGINAL PRICE
        Text(
          formatPrice(subscription.price),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.contentColorYellow.withValues(alpha: .35),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.white38,
            decorationThickness: 1.5,
          ),
        ),

        const SizedBox(height: 5),

        // PROMO PRICE
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(subscription.promoPrice!),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.contentColorYellow,
                height: 1,
                letterSpacing: -.9,
              ),
            ),

            const SizedBox(width: 7),

            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '/ ${subscription.durationText}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.contentColorYellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              size: 13,
              color: AppColors.contentColorYellow,
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Row(
                children: [
                  Text(
                    'limited time promotional price'.tr.capitalizeFirst ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (subscription.promoEndsAt != null &&
                      subscription.promoEndsAt!.isNotEmpty) ...[
                    const SizedBox(width: 6),

                    Text(
                      '• ${_formatPromoEndsAt(subscription.promoEndsAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageTabs(List<SubscriptionModel> subscriptions) {
    return Obx(() {
      final selectedIndex = subC.selectedIndex.value;

      return Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
        ),
        child: Row(
          children: List.generate(subscriptions.length, (index) {
            final SubscriptionModel subscription = subscriptions[index];
            final selected = index == selectedIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  subC.changePackage(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? AppColors.contentColorYellow
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subscription.name.tr.capitalize ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white54,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _SubscriptionInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _SubscriptionInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: AppColors.contentColorYellow),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title.tr,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value.tr,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// BENEFIT ITEM
// ==================================================================

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: AppColors.contentColorYellow),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text.tr,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
