import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prj_kulinerkito/controlers/crud_service.dart';
import 'package:prj_kulinerkito/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Minta izin Notifikasi
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  static Future<String> getAccesToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "kulinerkito-db",
      "private_key_id": "ceabd1e057dae1219fab40dfef021dd09340aa9c",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCj5uyyPOu116uH\nBGhpN6HvhQ4hRr7uxc3BXDZ+ZB2E8t9bvXWLTG/5tkx8kCfW6lJqxDTgY4RydZZb\nKcYPJAazqQ9NAnQLki5P1sqscNkHcs7XV5Qo1iwRWwGAgV2HKYnJi+DnUKtmChI0\nbPSau31Cx/isJZGOUAKXrlT6Jn400GTCoSB8Dpj3YmD9V6ivX6/HGvHMPO+91Mm0\n/hDai1Cm5O3XbF8pOYrAOPEi7gAu+XWsyinGwGItSpv30tfS5OebKZOJ7foBMI9o\ns+HXFUO3tEpuSVvw6q/eJfSY5je0nBd7JVe9VsyDzwg8S1EZcCGDzM4GkyJzzJxB\nY/EX8/oPAgMBAAECggEAC2lho4tQUgnhHHZ3GpRQBxA5iqGVW6SUDdlwxd4MnBwY\n5xdK3tcEmNtTefzDeVg5QsvEbrcfGqULQe+npZg5izrDIPaBw+h6pv5qgBUfV0Bs\nHFwxqaI30UGH2j2nmGiQ+mJt100rkeAzokjPwxI4x3SK4NmAx+rUM2Fk80HI2b5o\nJYi34hNvg+D2dFgMHRqQ7Hs9keOshcAIViMdFESJAcvq4jsIyjg1z2Z2wKFUbDiA\nyRc4jbi+vkDJQPHWbxG4vAqvZEWVh8Bfxqe9ndkiQVxlz7erbGkCcj2wa4ujK0L6\nZt2SkJD2oi0/IYnapmsoWjzjXMkahS2usIqITGYsiQKBgQDXwhAJj0/pAW3vziY9\nKDkIiMcIVeblCE3gaR3JIeUpNOySrbHIQj9TJiPyeuIajbOJT3zMXH12wEIcnJVu\nNeaJc93FVa6twg4jXJVxvIqIdsO1BoPsHLiVzZy7DM4X17NGmE2F/tB41tqTys+e\nihwEotzE1u8+hoyCa9WY7/L0XQKBgQDCeNwwS4qz0HNxDhBZdEMYoDgU72TGIHww\n0Zn4bPy0zqhCIe9hs7LodjdvBr6VXwTmKOa3Lw42YVV/w6StgO7k7V+yqOM+Qg6k\n4OPoIcsTiGEBV4fFcDHxCfbes95MPxULWsssAcNbL4Orb80JcuUY0Si5CFd11gMf\ntmf6hgHBWwKBgBqRVPQ4Z3ijqmvrEJ5bQ5qfbRLDsSjmuuA1UWug9tz6HV96b/fe\n4HlWqvqC0zC93iu8U/u+L9zdk8Z+KZBmprqqP9a61EWlLaSBFA3rT4u6RCMYaEo8\nxyX7KZ+G1iHtd6/rtTAYzobyvfuQ77vv+b9AZrr+VHt4ifjNWoH4mgwpAoGAZW1t\nwg6UP+Z3Xz6rjkxR9lUSCvE0yRUGUNvxBx2oy5CBN0TFulpj9FQ74z9MRVGyl2w7\nsMztB7XKRwG+MPPvJR0c7WyiYMVJJ/tXQqnlZcGafn2thW9XzNSamlqLlY7NJgfr\nsX8V6cglT1PXR5dSH5hvOdo862t8Y5zaLFKaNcMCgYAH5jsNM5zVFdR5wqpbZG53\nsgDkRSChfHi0TRHhgs19b/rheM2rIDMKSA1QfWxrKbPDdIlw7VPtnVrH/TP1/nde\nBAVwsJXCNqZ94UL6gJ33ZCq0pLBDN0x6DX2K68POM2ZRekksEWMKyFnUQJPIPGi/\nqeENeWnK00cqtesuCgd0Jg==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-notif-rich@kulinerkito-db.iam.gserviceaccount.com",
      "client_id": "114102705880461566197",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-notif-rich%40kulinerkito-db.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken,
      BuildContext context, String notificationType, String postId) async {
    final String serverAccessTokenKey = await getAccesToken();
    String endPointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/kulinerkito-db/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': notificationType == "login"
              ? "Selamat datang di KulinerKito"
              : "Komentar baru di postingan Anda",
          'body': notificationType == "login"
              ? "KulinerKito tempat mencari kuliner terbaik di Palembang"
              : "Seseorang telah berkomentar di postingan Anda",
        },
        'data': {
          'type': notificationType,
          'postId': postId,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send FCM message: ${response.statusCode}");
    }
  }

  static Future getDeviceToken() async {
    // Mendapatkan token FCM perangkat
    final token = await _firebaseMessaging.getToken();
    print("device token: $token");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUserLoggedin = prefs.getBool('isLoggedIn') ?? false;

    await CRUDService.saveUserToken(token!);
    print("Save to Firebase");
    return token;
  }

  // inisialisasi notifikasi lokal
  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: "Open Notifications");

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    // Minta izin untuk android 13 keatas
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed("/message", arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "your channel id",
      "your channel name",
      channelDescription: "your channel description",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
}
