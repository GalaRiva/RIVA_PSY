import 'package:flutter/material.dart';

import '../../../core/db/firebase_firestore/data/repository.dart';
import '../../../core/models/quiz/strength_trait.dart';
import '../../../core/user_data/user.dart';
import '../../../routes/app_routes.dart';
import 'bridge_screen.dart';
import 'loading_screen.dart';
import 'meditation_player_screen.dart';
import 'paywall_screen.dart';
import 'quiz_screen.dart';
import 'result_screen.dart';

const String _quizOneTimeFlag = 'strengths_quiz';

// Runs right after a brand-new account is created (never for an existing
// user signing back in) — Quiz → Loading → Result → Bridge → Paywall, then
// on to the app exactly where registration used to send the user directly.
// Skipping the quiz at any point still lands on the paywall; only the
// personalization data differs (no leading trait, but the welcome-offer
// countdown still applies — the discount isn't gated on having answered
// questions, just on being a brand-new account).
Future<void> startPostRegistrationQuizFlow(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StrengthsQuizScreen(
        onFinished: (quizCtx, quizController) {
          final top = quizController.computeTopTraits();
          Navigator.pushReplacement(
            quizCtx,
            MaterialPageRoute(
              builder: (_) => ProfileGenerationLoadingScreen(
                onComplete: (loadingCtx) {
                  Navigator.pushReplacement(
                    loadingCtx,
                    MaterialPageRoute(
                      builder: (_) => QuizResultScreen(
                        trait: top.isNotEmpty ? top.first : StrengthTrait.curiosity,
                        onContinue: (resultCtx) {
                          Navigator.pushReplacement(
                            resultCtx,
                            MaterialPageRoute(
                              builder: (_) => QuizBridgeScreen(
                                onListen: (bridgeCtx) {
                                  Navigator.pushReplacement(
                                    bridgeCtx,
                                    MaterialPageRoute(
                                      builder: (_) => MeditationPlayerScreen(
                                        onContinue: (playerCtx) => _showPaywall(playerCtx,
                                            leadingTrait: top.isNotEmpty ? top.first : null),
                                      ),
                                    ),
                                  );
                                },
                                onSkip: (bridgeCtx) => _showPaywall(bridgeCtx,
                                    leadingTrait: top.isNotEmpty ? top.first : null),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        onSkip: (skipCtx) => _showPaywall(skipCtx, leadingTrait: null),
      ),
    ),
  );
}

Future<void> _showPaywall(BuildContext context, {required StrengthTrait? leadingTrait}) async {
  final quizCompletedAt = DateTime.now();
  final userId = CurrentUser.repo.userId();
  if (userId.isNotEmpty) {
    await FireStoreRepositoryImpl().updateUser(
      userId: userId,
      quizCompletedAt: quizCompletedAt,
      quizLeadingTrait: leadingTrait?.name,
    );
    await FireStoreRepositoryImpl().completeOneTimeFlag(flagName: _quizOneTimeFlag);
  }
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => QuizPaywallScreen(
        quizCompletedAt: quizCompletedAt,
        onDone: _goToApp,
      ),
    ),
  );
}

void _goToApp(BuildContext context) {
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splashScreen, (route) => false);
}
