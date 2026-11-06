// Features held back on iOS for the first App Store release. Flip a flag to
// bring a feature back once the store side is ready (e.g. offer codes exist
// in App Store Connect — they can only be created after the app is live).
class ReleaseFlags {
  // "Ввести код Apple" button (Apple's offer-code redemption sheet). With no
  // offer codes created yet the sheet would open empty.
  static const bool iosAppleOfferCodeButton = false;
}
