
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSPolicyCheck {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<bool?> downloadPolicyCheck() async {

    DatabaseReference policyCheckRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/policyCheck");

    try {
      DatabaseEvent event = await policyCheckRef.once();
      final policyCheck = event.snapshot.value as bool?;
      debugPrint('downloadAdBannerVisibleConfirmTime policyCheck: $policyCheck');

      if (policyCheck != null) {
        return policyCheck;

      } else {
        debugPrint('return null;');

        try {
          await setFalsePolicyCheck();
        } catch (e) {
          debugPrint('setFalsePolicyCheck e: $e');
        }

        return null;
      }

    } catch (e) {
      debugPrint('downloadPolicyCheck e: $e');

      try {
        await setFalsePolicyCheck();
      } catch (e) {
        debugPrint('setFalsePolicyCheck e: $e');
      }

      return null;
    }

  }

  Future<void> updatePolicyCheck() async {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");

    try {
      Map<String, dynamic> updateData = {
        'policyCheck': true,
      };

      await ref.update(updateData);
    } catch (e) {
      debugPrint('updatePolicyCheck e: $e');
    }
  }

  Future<void> setFalsePolicyCheck() async {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");

    try {
      Map<String, dynamic> updateData = {
        'policyCheck': false,
      };

      await ref.update(updateData);
    } catch (e) {
      debugPrint('updatePolicyCheck e: $e');
    }
  }

}