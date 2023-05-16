import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class AuthorizationPage extends StatefulWidget {
  final Uri authorizationUrl;
  final void Function(Uri redicertUrl) onAuthorizationCodeRedirectAttempt;

  const AuthorizationPage(
      {Key? key,
      required this.authorizationUrl,
      required this.onAuthorizationCodeRedirectAttempt})
      : super(key: key);

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  final controller = WebViewController();
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(widget.authorizationUrl);
    controller.clearCache();
    WebViewCookieManager().clearCookies();
    controller.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) {
        if (request.url
            .startsWith(GitHubAuthenticator.redirectUrl.toString())) {
          widget.onAuthorizationCodeRedirectAttempt(Uri.parse(request.url));
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ));

    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
