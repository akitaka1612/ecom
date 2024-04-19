import 'package:bee2bee/screens/home.dart';
import 'package:bee2bee/screens/login.dart';
import 'package:bee2bee/screens/no_internet_screen.dart';
import 'package:bee2bee/screens/onboard.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  bool isViewed;
  String token;
  SplashScreen({Key? key, required this.isViewed, required this.token})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late RipplePageTransition _ripplePageTransition;
  final GlobalKey centerWidget = GlobalKey();

  @override
  void initState() {
    super.initState();
    print("in splash");
    setState(() {
      _ripplePageTransition = RipplePageTransition(centerWidget);
    });
    Future.delayed(
      const Duration(seconds: 2),
      () => _ripplePageTransition.navigateTo(
        widget.isViewed
            ? widget.token != ""
                ? HomeScreen()
                : LoginScreen(isEditing: false)
            : OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          // backgroundColor: Colors.white,
          body: Center(
            child: Image.asset(
              "assets/images/logo3.png",
              height: 250,
              width: 250,
              key: centerWidget,
            ),
          ),
        ),
        _ripplePageTransition,
      ],
    );
  }
}

// A widget for ripple page transition between pages.
class RipplePageTransition extends StatefulWidget {
  RipplePageTransition(
    this._originalWidgetKey,
    // this.color,
  );
  final GlobalKey _originalWidgetKey;
  // final Color color;
  final _state = _RipplePageTransitionState();

  void navigateTo(Widget page) => _state.startSpreadOutAnimation(page);

  @override
  _RipplePageTransitionState createState() => _state;
}

class _RipplePageTransitionState extends State<RipplePageTransition> {
  late Widget _page;
  late Rect _originalWidgetRect;
  Rect? _ripplePageTransitionRect;

  // Starts ripple effect from the original widget size to the whole screen.
  void startSpreadOutAnimation(Widget page) {
    if (!mounted) {
      return;
    }

    setState(() {
      _page = page;
      _originalWidgetRect = _getWidgetRect(widget._originalWidgetKey)!;
      _ripplePageTransitionRect = _originalWidgetRect;
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final fullscreenSize = 1.3 * MediaQuery.of(context).size.longestSide;
      // Expands the `_ripplePageTransitionRect` to cover the whole screen.
      setState(() {
        _ripplePageTransitionRect =
            _ripplePageTransitionRect!.inflate(fullscreenSize);
        return;
      });
    });
  }

  // Starts ripple effect from the whole screen to the original widget size.
  void _startShrinkInAnimation() =>
      setState(() => _ripplePageTransitionRect = _originalWidgetRect);

  Rect? _getWidgetRect(GlobalKey globalKey) {
    var renderObject = globalKey.currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    var size = renderObject?.semanticBounds.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ripplePageTransitionRect == null) {
      return Container();
    }

    return AnimatedPositioned.fromRect(
      rect: _ripplePageTransitionRect!,
      duration: Duration(milliseconds: 1500),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xffF3EAE1),
        ),
      ),
      onEnd: () {
        bool shouldNavigatePage =
            _ripplePageTransitionRect != _originalWidgetRect;
        if (shouldNavigatePage) {
          Navigator.pushAndRemoveUntil(
              context, FadeRouteBuilder(page: _page), (route) => false);
          //         .then((_) {
          //   _startShrinkInAnimation();
          // });
        } else {
          if (!mounted) {
            return;
          }

          // Dismiss ripple widget after shrinking finishes.
          setState(() => _ripplePageTransitionRect = null);
        }
      },
    );
  }
}

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  FadeRouteBuilder({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration(milliseconds: 100),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              FadeTransition(opacity: animation, child: child),
        );
}
