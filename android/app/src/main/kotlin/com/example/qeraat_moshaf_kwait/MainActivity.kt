

package kw.gov.qsa.quranapp

import android.os.Bundle
import com.google.android.play.core.assetpacks.AssetPackManager
import com.google.android.play.core.assetpacks.AssetPackManagerFactory
import com.google.android.play.core.assetpacks.AssetPackStates
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener

import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: AudioServiceActivity() {

    private lateinit var assetPackManager: AssetPackManager
    private val channelName = "play_asset_delivery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
    
        // Initialize the AssetPackManager
        assetPackManager = AssetPackManagerFactory.getInstance(applicationContext)

        // Set up the MethodChannel for communication with Flutter
        channel
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "testMethod" -> {
                        result.success("Test Method Called Successfully")
                    }
                    "downloadAssetPack" -> {
                        // Get the asset pack name from Flutter
                        val assetPackName = call.argument<String>("name")
                        if (assetPackName != null) {
                            downloadAssetPack(assetPackName, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Asset pack name is null", null)
                        }
                    }
                    "getAssetPackPath" -> {
                        val assetPackName = call.argument<String>("name")
                        if (assetPackName != null) {
                            getAssetPackPath(assetPackName, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Asset pack name is null", null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun downloadAssetPackSim(assetPackName: String, result: MethodChannel.Result) {
        // Simulate the download process for local testing
        val simulatedPath = "${applicationContext.filesDir}/$assetPackName/src/main/assets/"
        result.success("Simulated download: Asset Pack '$assetPackName' downloaded to $simulatedPath")
    }

    private fun getAssetPackPathSim(assetPackName: String, result: MethodChannel.Result) {
        // Simulate asset pack path for local testing
        val simulatedPath = "${applicationContext.filesDir}/$assetPackName/src/main/assets/"
        result.success(simulatedPath)
    }

    // Function to download an asset pack using Play Core API
    private fun downloadAssetPack(assetPackName: String, result: MethodChannel.Result) {
        assetPackManager.fetch(listOf(assetPackName))
            .addOnSuccessListener { assetPackStates: AssetPackStates ->
                // Successfully downloaded the asset pack
                result.success("Asset Pack '$assetPackName' downloaded successfully!")
            }
            .addOnFailureListener { e: Exception ->
                // Handle errors during the download
                result.error("ASSET_PACK_ERROR", "Failed to download asset pack: ${e.message}", null)
            }
    }

    private fun getAssetPackPath(assetPackName: String, result: MethodChannel.Result) {
        val assetLocation = "${assetPackManager.getPackLocation(assetPackName)?.assetsPath()}/${assetPackName}/src/main/assets/"
        if (assetLocation != null) {
            result.success(assetLocation) // Return the path to Flutter
        } else {
            result.error("ASSET_PATH_ERROR", "Failed to retrieve asset pack path.", null)
        }
    }



}

