// lib/services/call_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> call(BuildContext context, String phone) async {
    if (phone.trim().isEmpty) {
      _toast(context, 'Phone number is empty');
      return;
    }

    if (Platform.isAndroid) {
      final status = await Permission.phone.request();
      if (!status.isGranted) {
        _toast(context, 'Phone permission required to place calls');
        return;
      }

      final ok = await FlutterPhoneDirectCaller.callNumber(phone);
      if (ok != true) {
        _toast(context, 'Unable to place call');
      }
      return;
    }

    // iOS: direct call not allowed, fallback to dialer
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast(context, 'Unable to open dialer');
    }
  }

  static void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
