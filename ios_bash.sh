cd ios
rm -rf Pods
rm -rf Podfile.lock
pod cache clean --all
flutter clean
flutter pub get
cd ios
pod install