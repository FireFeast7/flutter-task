import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final Future<void> Function() loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError, {final Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
          title: Center(child: const Text('Auth0 Demo')),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await loginAction();
              },
              child: const Text('Login/Register'),
            ),
            Text(loginError),
          ],
        ),
      ),
    );
  }
}
