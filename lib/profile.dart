import 'package:flutter/material.dart';
import 'package:flutterdemo/networking.dart';

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;

  const Profile(this.logoutAction, {final Key? key}) : super(key: key);

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
                  await performAuthorizedRequest();
                },
                child: Text('Get User Info')),
            ElevatedButton(
                onPressed: () async {
                  await askingAuth();
                },
                child: Text('Get Testing Auth Token')),
            ElevatedButton(
              onPressed: () async {
                await logoutAction();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
