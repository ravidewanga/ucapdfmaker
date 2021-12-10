package com.example.ucapdfmaker

import android.app.ActivityManager
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ucanapply.ravi/flutter_ravi";

    // Allowlist two apps.
    private val KIOSK_PACKAGE = "com.example.kiosk"
    private val PLAYER_PACKAGE = "com.example.player"
    private val APP_PACKAGES = arrayOf(KIOSK_PACKAGE, PLAYER_PACKAGE)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //---for diable screen short-------
        //window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);

        //----full screen mode-----
        //window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        // this.window.setType(WindowManager.LayoutParams.TYPE_KEYGUARD_DIALOG);

//        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
        //window.addFlags(WindowManager.LayoutParams.TYPE_KEYGUARD_DIALOG);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if(call.method == "isInLockTaskMode"){
                var taskMode =  checkLockTask();
                result.success(taskMode)
            } else if(call.method == "isRunning"){
                //-------
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }

    fun checkLockTask(): Int {
        val activityManager = context
                .getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return activityManager.lockTaskModeState;
    }

    fun isAppRunning(context: Context, packageName: String?): Boolean {
        val activityManager: ActivityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val procInfos: List<ActivityManager.RunningAppProcessInfo> = activityManager.getRunningAppProcesses()
        if (procInfos != null) {
            for (processInfo in procInfos) {
                if (processInfo.processName.equals(packageName)) {
                    return true
                }
            }
        }
        return false
    }

}
