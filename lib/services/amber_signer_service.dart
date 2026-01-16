import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AmberSignerService');

/// Response from the Amber signer.
class AmberSignerResponse {
  final String? result;
  final String? packageName;
  final String? event;
  final String? id;

  const AmberSignerResponse({
    this.result,
    this.packageName,
    this.event,
    this.id,
  });

  factory AmberSignerResponse.fromMap(Map<Object?, Object?> map) {
    return AmberSignerResponse(
      result: map['result'] as String?,
      packageName: map['package'] as String?,
      event: map['event'] as String?,
      id: map['id'] as String?,
    );
  }

  @override
  String toString() => 'AmberSignerResponse(result: $result, package: $packageName, id: $id)';
}

/// Permission request for Amber signer.
class AmberPermission {
  final String type;
  final int? kind;

  const AmberPermission({
    required this.type,
    this.kind,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type};
    if (kind != null) {
      map['kind'] = kind;
    }
    return map;
  }
}

/// Exception thrown when Amber signer operations fail.
class AmberSignerException implements Exception {
  final String code;
  final String message;

  const AmberSignerException(this.code, this.message);

  @override
  String toString() => 'AmberSignerException($code): $message';
}

/// Service for communicating with Amber signer via NIP-55.
///
/// This service implements the NIP-55 protocol for Android signer applications.
/// It uses platform channels to communicate with the native Android code
/// that handles intents and content resolvers.
class AmberSignerService {
  static const _channel = MethodChannel('com.example.sloth/amber_signer');

  const AmberSignerService();

  /// Checks if an external signer app (like Amber) is installed.
  ///
  /// Returns `true` if a signer is available, `false` otherwise.
  /// On non-Android platforms, always returns `false`.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('isExternalSignerInstalled');
      _logger.fine('External signer available: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.warning('Failed to check signer availability: ${e.message}');
      return false;
    }
  }

  /// Requests the public key from the external signer.
  ///
  /// This initiates the connection with the signer and should be called first.
  /// The signer will prompt the user to select an account and authorize the app.
  ///
  /// [permissions] - Optional list of permissions to request upfront.
  ///
  /// Returns the user's public key (hex format) and saves the signer package name.
  /// Throws [AmberSignerException] if the request fails or is rejected.
  Future<String> getPublicKey({List<AmberPermission>? permissions}) async {
    _logger.info('Requesting public key from signer');

    try {
      final args = <String, dynamic>{};
      if (permissions != null && permissions.isNotEmpty) {
        args['permissions'] = jsonEncode(permissions.map((p) => p.toJson()).toList());
      }

      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getPublicKey', args);
      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      _logger.info('Got public key from signer: ${response.result?.substring(0, 8)}...');

      if (response.result == null || response.result!.isEmpty) {
        throw const AmberSignerException('NO_PUBKEY', 'Signer did not return a public key');
      }

      return response.result!;
    } on PlatformException catch (e) {
      _logger.warning('Failed to get public key: ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Signs a Nostr event using the external signer.
  ///
  /// [eventJson] - The unsigned event JSON to sign.
  /// [id] - Optional request ID for tracking multiple concurrent requests.
  /// [currentUser] - The currently logged in user's public key (hex).
  ///
  /// Returns a map containing:
  /// - `signature`: The event signature
  /// - `event`: The full signed event JSON (if available)
  ///
  /// Throws [AmberSignerException] if signing fails or is rejected.
  Future<AmberSignerResponse> signEvent({
    required String eventJson,
    String? id,
    String? currentUser,
  }) async {
    _logger.info('Requesting event signature from signer');

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('signEvent', {
        'eventJson': eventJson,
        'id': id ?? '',
        'currentUser': currentUser ?? '',
      });

      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      _logger.fine('Got signature from signer');
      return response;
    } on PlatformException catch (e) {
      _logger.warning('Failed to sign event: ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Encrypts text using NIP-04.
  ///
  /// [plaintext] - The text to encrypt.
  /// [pubkey] - The recipient's public key (hex).
  /// [currentUser] - The sender's public key (hex).
  /// [id] - Optional request ID.
  ///
  /// Returns the encrypted text.
  Future<String> nip04Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    _logger.info('Requesting NIP-04 encryption from signer');

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('nip04Encrypt', {
        'plaintext': plaintext,
        'pubkey': pubkey,
        'currentUser': currentUser ?? '',
        'id': id ?? '',
      });

      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      if (response.result == null || response.result!.isEmpty) {
        throw const AmberSignerException('NO_RESULT', 'Signer did not return encrypted text');
      }

      return response.result!;
    } on PlatformException catch (e) {
      _logger.warning('Failed to encrypt (NIP-04): ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Decrypts text using NIP-04.
  ///
  /// [encryptedText] - The text to decrypt.
  /// [pubkey] - The sender's public key (hex).
  /// [currentUser] - The recipient's public key (hex).
  /// [id] - Optional request ID.
  ///
  /// Returns the decrypted plaintext.
  Future<String> nip04Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    _logger.info('Requesting NIP-04 decryption from signer');

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('nip04Decrypt', {
        'encryptedText': encryptedText,
        'pubkey': pubkey,
        'currentUser': currentUser ?? '',
        'id': id ?? '',
      });

      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      if (response.result == null || response.result!.isEmpty) {
        throw const AmberSignerException('NO_RESULT', 'Signer did not return decrypted text');
      }

      return response.result!;
    } on PlatformException catch (e) {
      _logger.warning('Failed to decrypt (NIP-04): ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Encrypts text using NIP-44.
  ///
  /// [plaintext] - The text to encrypt.
  /// [pubkey] - The recipient's public key (hex).
  /// [currentUser] - The sender's public key (hex).
  /// [id] - Optional request ID.
  ///
  /// Returns the encrypted text.
  Future<String> nip44Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    _logger.info('Requesting NIP-44 encryption from signer');

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('nip44Encrypt', {
        'plaintext': plaintext,
        'pubkey': pubkey,
        'currentUser': currentUser ?? '',
        'id': id ?? '',
      });

      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      if (response.result == null || response.result!.isEmpty) {
        throw const AmberSignerException('NO_RESULT', 'Signer did not return encrypted text');
      }

      return response.result!;
    } on PlatformException catch (e) {
      _logger.warning('Failed to encrypt (NIP-44): ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Decrypts text using NIP-44.
  ///
  /// [encryptedText] - The text to decrypt.
  /// [pubkey] - The sender's public key (hex).
  /// [currentUser] - The recipient's public key (hex).
  /// [id] - Optional request ID.
  ///
  /// Returns the decrypted plaintext.
  Future<String> nip44Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    _logger.info('Requesting NIP-44 decryption from signer');

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('nip44Decrypt', {
        'encryptedText': encryptedText,
        'pubkey': pubkey,
        'currentUser': currentUser ?? '',
        'id': id ?? '',
      });

      if (result == null) {
        throw const AmberSignerException('NO_RESPONSE', 'No response from signer');
      }

      final response = AmberSignerResponse.fromMap(result);
      if (response.result == null || response.result!.isEmpty) {
        throw const AmberSignerException('NO_RESULT', 'Signer did not return decrypted text');
      }

      return response.result!;
    } on PlatformException catch (e) {
      _logger.warning('Failed to decrypt (NIP-44): ${e.code} - ${e.message}');
      throw AmberSignerException(e.code, e.message ?? 'Unknown error');
    }
  }

  /// Gets the saved signer package name.
  ///
  /// Returns the package name if previously connected, null otherwise.
  Future<String?> getSignerPackageName() async {
    try {
      return await _channel.invokeMethod<String>('getSignerPackageName');
    } on PlatformException catch (e) {
      _logger.warning('Failed to get signer package name: ${e.message}');
      return null;
    }
  }

  /// Sets the signer package name.
  ///
  /// This is typically set automatically after a successful [getPublicKey] call.
  Future<void> setSignerPackageName(String packageName) async {
    try {
      await _channel.invokeMethod<void>('setSignerPackageName', {
        'packageName': packageName,
      });
    } on PlatformException catch (e) {
      _logger.warning('Failed to set signer package name: ${e.message}');
    }
  }
}
