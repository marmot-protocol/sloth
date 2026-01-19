package com.example.sloth

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/**
 * NIP-55 Android Signer Plugin for Amber integration.
 *
 * Implements the NIP-55 protocol for communicating with external signer apps
 * like Amber on Android using Intents and Content Resolvers.
 *
 * Content Resolvers are used for background operations when the user has
 * previously approved "remember my choice". If Content Resolver returns null
 * or rejected, falls back to Intent (which shows a popup).
 */
class AmberSignerPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private var currentRequestId: String? = null

    companion object {
        private const val CHANNEL_NAME = "com.example.sloth/amber_signer"
        private const val REQUEST_CODE_SIGNER = 1001
        private const val NOSTRSIGNER_SCHEME = "nostrsigner"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        when (call.method) {
            "isExternalSignerInstalled" -> {
                result.success(isExternalSignerInstalled())
            }

            "getPublicKey" -> {
                val permissions = call.argument<String>("permissions")
                getPublicKey(permissions, result)
            }

            "signEvent" -> {
                val eventJson =
                    call.argument<String>("eventJson") ?: run {
                        result.error("INVALID_ARGUMENT", "eventJson is required", null)
                        return
                    }
                val id = call.argument<String>("id") ?: ""
                val currentUser = call.argument<String>("currentUser") ?: ""
                signEvent(eventJson, id, currentUser, result)
            }

            "nip04Encrypt" -> {
                val plaintext =
                    call.argument<String>("plaintext") ?: run {
                        result.error("INVALID_ARGUMENT", "plaintext is required", null)
                        return
                    }
                val pubkey =
                    call.argument<String>("pubkey") ?: run {
                        result.error("INVALID_ARGUMENT", "pubkey is required", null)
                        return
                    }
                val currentUser = call.argument<String>("currentUser") ?: ""
                val id = call.argument<String>("id") ?: ""
                nip04Encrypt(plaintext, pubkey, currentUser, id, result)
            }

            "nip04Decrypt" -> {
                val encryptedText =
                    call.argument<String>("encryptedText") ?: run {
                        result.error("INVALID_ARGUMENT", "encryptedText is required", null)
                        return
                    }
                val pubkey =
                    call.argument<String>("pubkey") ?: run {
                        result.error("INVALID_ARGUMENT", "pubkey is required", null)
                        return
                    }
                val currentUser = call.argument<String>("currentUser") ?: ""
                val id = call.argument<String>("id") ?: ""
                nip04Decrypt(encryptedText, pubkey, currentUser, id, result)
            }

            "nip44Encrypt" -> {
                val plaintext =
                    call.argument<String>("plaintext") ?: run {
                        result.error("INVALID_ARGUMENT", "plaintext is required", null)
                        return
                    }
                val pubkey =
                    call.argument<String>("pubkey") ?: run {
                        result.error("INVALID_ARGUMENT", "pubkey is required", null)
                        return
                    }
                val currentUser = call.argument<String>("currentUser") ?: ""
                val id = call.argument<String>("id") ?: ""
                nip44Encrypt(plaintext, pubkey, currentUser, id, result)
            }

            "nip44Decrypt" -> {
                val encryptedText =
                    call.argument<String>("encryptedText") ?: run {
                        result.error("INVALID_ARGUMENT", "encryptedText is required", null)
                        return
                    }
                val pubkey =
                    call.argument<String>("pubkey") ?: run {
                        result.error("INVALID_ARGUMENT", "pubkey is required", null)
                        return
                    }
                val currentUser = call.argument<String>("currentUser") ?: ""
                val id = call.argument<String>("id") ?: ""
                nip44Decrypt(encryptedText, pubkey, currentUser, id, result)
            }

            "getSignerPackageName" -> {
                result.success(getSignerPackageName())
            }

            "setSignerPackageName" -> {
                val packageName =
                    call.argument<String>("packageName") ?: run {
                        result.error("INVALID_ARGUMENT", "packageName is required", null)
                        return
                    }
                setSignerPackageName(packageName)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun isExternalSignerInstalled(): Boolean {
        val context = activity ?: return false
        val intent =
            Intent().apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse("$NOSTRSIGNER_SCHEME:")
            }
        val infos = context.packageManager.queryIntentActivities(intent, 0)
        return infos.isNotEmpty()
    }

    private fun getPublicKey(
        permissions: String?,
        result: Result,
    ) {
        val currentActivity =
            activity ?: run {
                result.error("NO_ACTIVITY", "Activity not available", null)
                return
            }

        pendingResult = result
        currentRequestId = null

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("$NOSTRSIGNER_SCHEME:"))
        intent.putExtra("type", "get_public_key")

        if (!permissions.isNullOrEmpty()) {
            intent.putExtra("permissions", permissions)
        }

        try {
            currentActivity.startActivityForResult(intent, REQUEST_CODE_SIGNER)
        } catch (e: android.content.ActivityNotFoundException) {
            pendingResult = null
            result.error("NO_SIGNER", "No signer app found: ${e.message}", null)
        } catch (e: Exception) {
            pendingResult = null
            result.error("LAUNCH_ERROR", "Failed to launch signer: ${e.message}", null)
        }
    }

    private fun signEvent(
        eventJson: String,
        id: String,
        currentUser: String,
        result: Result,
    ) {
        val packageName = getSignerPackageName()
        if (packageName.isNullOrEmpty()) {
            result.error("NO_SIGNER", "Signer package name not set. Call getPublicKey first.", null)
            return
        }

        // Try Content Resolver first (background, no popup)
        val contentResult = trySignEventViaContentResolver(eventJson, currentUser, packageName)
        if (contentResult != null) {
            val response = mutableMapOf<String, Any?>()
            response["result"] = contentResult["signature"]
            response["event"] = contentResult["event"]
            response["id"] = id
            result.success(response)
            return
        }

        // Fall back to Intent (shows popup)
        val currentActivity =
            activity ?: run {
                result.error("NO_ACTIVITY", "Activity not available", null)
                return
            }

        pendingResult = result
        currentRequestId = id

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("$NOSTRSIGNER_SCHEME:$eventJson"))
        intent.`package` = packageName
        intent.putExtra("type", "sign_event")
        intent.putExtra("id", id)
        if (currentUser.isNotEmpty()) {
            intent.putExtra("current_user", currentUser)
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)

        try {
            currentActivity.startActivityForResult(intent, REQUEST_CODE_SIGNER)
        } catch (e: Exception) {
            pendingResult = null
            currentRequestId = null
            result.error("LAUNCH_ERROR", "Failed to launch signer: ${e.message}", null)
        }
    }

    /**
     * Tries to sign an event using Content Resolver (background, no popup).
     * Returns null if not available or user hasn't approved "remember my choice".
     */
    private fun trySignEventViaContentResolver(
        eventJson: String,
        currentUser: String,
        packageName: String,
    ): Map<String, String?>? {
        val ctx = context ?: return null

        try {
            val uri = Uri.parse("content://$packageName.SIGN_EVENT")
            val cursor =
                ctx.contentResolver.query(
                    uri,
                    arrayOf(eventJson, "", currentUser),
                    null,
                    null,
                    null,
                )

            cursor?.use {
                // Check if rejected
                if (it.getColumnIndex("rejected") >= 0) {
                    return null
                }

                if (it.moveToFirst()) {
                    val resultIndex = it.getColumnIndex("result")
                    val eventIndex = it.getColumnIndex("event")

                    if (resultIndex >= 0) {
                        return mapOf(
                            "signature" to it.getString(resultIndex),
                            "event" to if (eventIndex >= 0) it.getString(eventIndex) else null,
                        )
                    }
                }
            }
        } catch (e: Exception) {
            // Content resolver not available, fall back to intent
            android.util.Log.d("AmberSignerPlugin", "Content resolver failed, falling back to intent: ${e.message}")
        }

        return null
    }

    private fun nip04Encrypt(
        plaintext: String,
        pubkey: String,
        currentUser: String,
        id: String,
        result: Result,
    ) {
        launchSignerIntent("nip04_encrypt", plaintext, pubkey, currentUser, id, result)
    }

    private fun nip04Decrypt(
        encryptedText: String,
        pubkey: String,
        currentUser: String,
        id: String,
        result: Result,
    ) {
        launchSignerIntent("nip04_decrypt", encryptedText, pubkey, currentUser, id, result)
    }

    private fun nip44Encrypt(
        plaintext: String,
        pubkey: String,
        currentUser: String,
        id: String,
        result: Result,
    ) {
        launchSignerIntent("nip44_encrypt", plaintext, pubkey, currentUser, id, result)
    }

    private fun nip44Decrypt(
        encryptedText: String,
        pubkey: String,
        currentUser: String,
        id: String,
        result: Result,
    ) {
        launchSignerIntent("nip44_decrypt", encryptedText, pubkey, currentUser, id, result)
    }

    private fun launchSignerIntent(
        type: String,
        content: String,
        pubkey: String,
        currentUser: String,
        id: String,
        result: Result,
    ) {
        val packageName = getSignerPackageName()
        if (packageName.isNullOrEmpty()) {
            result.error("NO_SIGNER", "Signer package name not set. Call getPublicKey first.", null)
            return
        }

        // Try Content Resolver first (background, no popup)
        val contentResult = tryEncryptDecryptViaContentResolver(type, content, pubkey, currentUser, packageName)
        if (contentResult != null) {
            val response = mutableMapOf<String, Any?>()
            response["result"] = contentResult
            response["id"] = id
            result.success(response)
            return
        }

        // Fall back to Intent (shows popup)
        val currentActivity =
            activity ?: run {
                result.error("NO_ACTIVITY", "Activity not available", null)
                return
            }

        pendingResult = result
        currentRequestId = id

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("$NOSTRSIGNER_SCHEME:$content"))
        intent.`package` = packageName
        intent.putExtra("type", type)
        intent.putExtra("pubkey", pubkey)
        if (currentUser.isNotEmpty()) {
            intent.putExtra("current_user", currentUser)
        }
        if (id.isNotEmpty()) {
            intent.putExtra("id", id)
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)

        try {
            currentActivity.startActivityForResult(intent, REQUEST_CODE_SIGNER)
        } catch (e: Exception) {
            pendingResult = null
            currentRequestId = null
            result.error("LAUNCH_ERROR", "Failed to launch signer: ${e.message}", null)
        }
    }

    /**
     * Tries to encrypt/decrypt using Content Resolver (background, no popup).
     * Returns null if not available or user hasn't approved "remember my choice".
     */
    private fun tryEncryptDecryptViaContentResolver(
        type: String,
        content: String,
        pubkey: String,
        currentUser: String,
        packageName: String,
    ): String? {
        val ctx = context ?: return null

        // Map method type to Content Resolver path
        val contentResolverType =
            when (type) {
                "nip04_encrypt" -> "NIP04_ENCRYPT"
                "nip04_decrypt" -> "NIP04_DECRYPT"
                "nip44_encrypt" -> "NIP44_ENCRYPT"
                "nip44_decrypt" -> "NIP44_DECRYPT"
                else -> return null
            }

        try {
            val uri = Uri.parse("content://$packageName.$contentResolverType")
            val cursor =
                ctx.contentResolver.query(
                    uri,
                    arrayOf(content, pubkey, currentUser),
                    null,
                    null,
                    null,
                )

            cursor?.use {
                // Check if rejected
                if (it.getColumnIndex("rejected") >= 0) {
                    return null
                }

                if (it.moveToFirst()) {
                    val resultIndex = it.getColumnIndex("result")
                    if (resultIndex >= 0) {
                        return it.getString(resultIndex)
                    }
                }
            }
        } catch (e: Exception) {
            // Content resolver not available, fall back to intent
            android.util.Log.d("AmberSignerPlugin", "Content resolver failed for $type, falling back to intent: ${e.message}")
        }

        return null
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ): Boolean {
        if (requestCode != REQUEST_CODE_SIGNER) {
            return false
        }

        val result = pendingResult ?: return true
        pendingResult = null
        val requestId = currentRequestId
        currentRequestId = null

        if (resultCode != Activity.RESULT_OK) {
            result.error("USER_REJECTED", "User rejected the request", null)
            return true
        }

        if (data == null) {
            result.error("NO_DATA", "No data returned from signer", null)
            return true
        }

        // Extract result data
        val resultValue = data.getStringExtra("result")
        val packageName = data.getStringExtra("package")
        val eventJson = data.getStringExtra("event")
        val id = data.getStringExtra("id")

        // Save package name if returned (from get_public_key)
        if (!packageName.isNullOrEmpty()) {
            setSignerPackageName(packageName)
        }

        // Build response map
        val response = mutableMapOf<String, Any?>()
        response["result"] = resultValue
        response["package"] = packageName
        response["event"] = eventJson
        response["id"] = id ?: requestId

        result.success(response)
        return true
    }

    private fun getSignerPackageName(): String? {
        val context = activity ?: return null
        val prefs = context.getSharedPreferences("amber_signer_prefs", Context.MODE_PRIVATE)
        return prefs.getString("signer_package_name", null)
    }

    private fun setSignerPackageName(packageName: String) {
        val context = activity ?: return
        val prefs = context.getSharedPreferences("amber_signer_prefs", Context.MODE_PRIVATE)
        prefs.edit().putString("signer_package_name", packageName).apply()
    }
}
