package com.app.fy.flutter.play_flutter

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Address
import android.location.Geocoder
import android.location.Location
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.location.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

/**
 * 主Activity，处理Flutter与原生Android的通信
 * 实现基于Google Play Services的定位功能
 *
 * 修复内容：
 * 1. 适配 Android 10+ 后台定位权限
 * 2. 适配 Android 12+ 精确/粗略定位权限
 * 3. 添加定位超时处理
 * 4. 添加 Google Play Services 可用性检查
 * 5. 优化权限请求流程
 * 6. 添加详细的GPS定位日志输出
 * 7. 添加 Android 原生 Geocoder 反向地理编码
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "LocationDebug"  // 日志标签
        private const val LOCATION_CHANNEL = "com.app.fy.flutter.play_flutter/location"
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1001
        private const val BACKGROUND_LOCATION_REQUEST_CODE = 1002
        private const val LOCATION_TIMEOUT_MS = 15000L // 15秒超时
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var pendingResult: MethodChannel.Result? = null
    private var locationCallback: LocationCallback? = null
    private val handler = Handler(Looper.getMainLooper())
    private var timeoutRunnable: Runnable? = null

    /**
     * 配置Flutter引擎，设置MethodChannel
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "=== MainActivity 初始化 ===")
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        Log.d(TAG, "FusedLocationProviderClient 初始化完成")

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCATION_CHANNEL
        ).setMethodCallHandler { call, result ->
            Log.d(TAG, "收到 Flutter 调用: ${call.method}")
            when (call.method) {
                "getCurrentLocation" -> {
                    getCurrentLocation(result)
                }
                "checkPermission" -> {
                    val permission = checkLocationPermission()
                    Log.d(TAG, "权限检查结果: $permission")
                    result.success(permission)
                }
                "requestPermission" -> {
                    pendingResult = result
                    requestLocationPermission()
                }
                "checkGooglePlayServices" -> {
                    val available = checkGooglePlayServices()
                    Log.d(TAG, "Google Play Services 可用性: $available")
                    result.success(available)
                }
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(null)
                }
                "getCityNameFromCoordinates" -> {
                    // 获取参数
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    
                    if (latitude == null || longitude == null) {
                        result.error("INVALID_ARGUMENTS", "纬度或经度参数缺失", null)
                        return@setMethodCallHandler
                    }
                    
                    getCityNameFromCoordinates(latitude, longitude, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * 使用 Android 原生 Geocoder 根据坐标获取城市名
     */
    private fun getCityNameFromCoordinates(
        latitude: Double, 
        longitude: Double, 
        result: MethodChannel.Result
    ) {
        Log.d(TAG, "=== 开始反向地理编码 ===")
        Log.d(TAG, "坐标: 纬度=$latitude, 经度=$longitude")
        
        try {
            val geocoder = Geocoder(this, Locale.getDefault())
            
            // Android 13+ 使用异步 API
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                geocoder.getFromLocation(latitude, longitude, 1) { addresses ->
                    handleGeocoderResult(addresses, result)
                }
            } else {
                // Android 12 及以下使用同步 API（需要在后台线程执行）
                Thread {
                    try {
                        @Suppress("DEPRECATION")
                        val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                        runOnUiThread {
                            handleGeocoderResult(addresses, result)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Geocoder 错误: ${e.message}")
                        runOnUiThread {
                            result.error("GEOCODER_ERROR", e.message, null)
                        }
                    }
                }.start()
            }
        } catch (e: Exception) {
            Log.e(TAG, "创建 Geocoder 失败: ${e.message}")
            result.error("GEOCODER_ERROR", e.message, null)
        }
    }
    
    /**
     * 处理 Geocoder 返回结果
     */
    private fun handleGeocoderResult(addresses: List<Address>?, result: MethodChannel.Result) {
        if (addresses.isNullOrEmpty()) {
            Log.w(TAG, "Geocoder 未返回地址信息")
            result.success(null)
            return
        }
        
        val address = addresses[0]
        
        // 提取地址信息
        val cityName = address.locality  // 城市
            ?: address.subAdminArea      // 区/县
            ?: address.adminArea         // 省/州
            ?: "未知位置"
        
        val country = address.countryName  // 国家
        val admin1 = address.adminArea     // 省/州
        
        Log.d(TAG, "反向地理编码成功:")
        Log.d(TAG, "  城市: $cityName")
        Log.d(TAG, "  省份: $admin1")
        Log.d(TAG, "  国家: $country")
        Log.d(TAG, "  完整地址: ${address.getAddressLine(0)}")
        
        // 返回结果给 Flutter
        val resultMap = mapOf(
            "cityName" to cityName,
            "country" to country,
            "admin1" to admin1,
            "latitude" to address.latitude,
            "longitude" to address.longitude
        )
        
        result.success(resultMap)
    }

    /**
     * 检查 Google Play Services 是否可用
     */
    private fun checkGooglePlayServices(): Boolean {
        val googleApiAvailability = GoogleApiAvailability.getInstance()
        val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(this)
        val isAvailable = resultCode == ConnectionResult.SUCCESS
        Log.d(TAG, "Google Play Services 检查结果: $isAvailable (code: $resultCode)")
        return isAvailable
    }

    /**
     * 检查位置权限状态
     * @return 权限状态字符串: "granted", "coarse", "denied", "denied_permanently"
     */
    private fun checkLocationPermission(): String {
        val fineLocationGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val coarseLocationGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        Log.d(TAG, "权限状态 - 精确位置: $fineLocationGranted, 粗略位置: $coarseLocationGranted")

        return when {
            fineLocationGranted -> {
                Log.d(TAG, "权限状态: granted (精确位置)")
                "granted"
            }
            coarseLocationGranted -> {
                Log.d(TAG, "权限状态: coarse (粗略位置)")
                "coarse"
            }
            else -> {
                // 检查是否被永久拒绝
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(
                        this,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    )
                    val isFirstTime = isFirstTimeRequestingPermission()
                    Log.d(TAG, "权限被拒绝 - shouldShowRationale: $shouldShowRationale, isFirstTime: $isFirstTime")
                    if (!shouldShowRationale && !isFirstTime) {
                        Log.d(TAG, "权限状态: denied_permanently (永久拒绝)")
                        "denied_permanently"
                    } else {
                        Log.d(TAG, "权限状态: denied (临时拒绝)")
                        "denied"
                    }
                } else {
                    Log.d(TAG, "权限状态: denied")
                    "denied"
                }
            }
        }
    }

    /**
     * 检查是否是第一次请求权限
     */
    private fun isFirstTimeRequestingPermission(): Boolean {
        val prefs = getSharedPreferences("location_prefs", MODE_PRIVATE)
        val isFirstTime = prefs.getBoolean("first_time_request", true)
        if (isFirstTime) {
            prefs.edit().putBoolean("first_time_request", false).apply()
        }
        return isFirstTime
    }

    /**
     * 请求位置权限
     * 适配 Android 10+ 和 Android 12+ 的权限模型
     */
    private fun requestLocationPermission() {
        Log.d(TAG, "=== 开始请求位置权限 ===")
        val permissionsToRequest = mutableListOf<String>()

        // 首先请求前台定位权限
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.ACCESS_FINE_LOCATION)
            Log.d(TAG, "需要请求 ACCESS_FINE_LOCATION 权限")
        }
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.ACCESS_COARSE_LOCATION)
            Log.d(TAG, "需要请求 ACCESS_COARSE_LOCATION 权限")
        }

        if (permissionsToRequest.isNotEmpty()) {
            Log.d(TAG, "请求权限列表: $permissionsToRequest")
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray(),
                LOCATION_PERMISSION_REQUEST_CODE
            )
        } else {
            Log.d(TAG, "前台权限已授予")
            // 前台权限已授予，检查后台权限（Android 10+）
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                requestBackgroundLocationPermission()
            } else {
                pendingResult?.success("granted")
                pendingResult = null
            }
        }
    }

    /**
     * 请求后台定位权限（Android 10+）
     */
    private fun requestBackgroundLocationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION
                ) != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "请求后台定位权限 (Android 10+)")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                    BACKGROUND_LOCATION_REQUEST_CODE
                )
            } else {
                Log.d(TAG, "后台权限已授予")
                pendingResult?.success("granted")
                pendingResult = null
            }
        } else {
            pendingResult?.success("granted")
            pendingResult = null
        }
    }

    /**
     * 权限请求结果回调
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        Log.d(TAG, "=== 权限请求结果回调 ===")
        Log.d(TAG, "requestCode: $requestCode")
        Log.d(TAG, "permissions: ${permissions.toList()}")
        Log.d(TAG, "grantResults: ${grantResults.toList()}")

        when (requestCode) {
            LOCATION_PERMISSION_REQUEST_CODE -> {
                handleLocationPermissionResult(permissions, grantResults)
            }
            BACKGROUND_LOCATION_REQUEST_CODE -> {
                // 后台权限请求结果
                val result = if (grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Log.d(TAG, "后台权限授予成功")
                    "granted"
                } else {
                    Log.d(TAG, "后台权限被拒绝")
                    // 后台权限被拒绝，但前台权限可能已授予
                    checkLocationPermission()
                }
                pendingResult?.success(result)
                pendingResult = null
            }
        }
    }

    /**
     * 处理位置权限结果
     */
    private fun handleLocationPermissionResult(
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        var fineGranted = false
        var coarseGranted = false

        for (i in permissions.indices) {
            if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                when (permissions[i]) {
                    Manifest.permission.ACCESS_FINE_LOCATION -> fineGranted = true
                    Manifest.permission.ACCESS_COARSE_LOCATION -> coarseGranted = true
                }
            }
        }

        Log.d(TAG, "权限结果处理 - 精确位置: $fineGranted, 粗略位置: $coarseGranted")

        val result = when {
            fineGranted -> {
                Log.d(TAG, "精确位置权限已授予")
                // 前台精确权限已授予，检查是否需要后台权限
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // 延迟请求后台权限，避免一次性请求过多权限
                    pendingResult?.success("granted")
                    pendingResult = null
                    return
                }
                "granted"
            }
            coarseGranted -> {
                Log.d(TAG, "粗略位置权限已授予")
                "coarse"
            }
            else -> {
                // 检查是否被永久拒绝
                val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(
                    this,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                Log.d(TAG, "权限被拒绝 - shouldShowRationale: $shouldShowRationale")
                if (!shouldShowRationale) "denied_permanently" else "denied"
            }
        }

        pendingResult?.success(result)
        pendingResult = null
    }

    /**
     * 打开应用设置页面
     */
    private fun openAppSettings() {
        Log.d(TAG, "打开应用设置页面")
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    /**
     * 获取当前位置
     * 首先尝试获取缓存位置，如果为空则请求新位置
     */
    private fun getCurrentLocation(result: MethodChannel.Result) {
        Log.d(TAG, "=== 开始获取当前位置 ===")

        // 检查 Google Play Services
        if (!checkGooglePlayServices()) {
            Log.e(TAG, "Google Play Services 不可用，无法获取位置")
            result.error("GOOGLE_PLAY_SERVICES_NOT_AVAILABLE", "Google Play Services 不可用", null)
            return
        }

        // 检查权限
        val fineGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        Log.d(TAG, "权限检查 - 精确位置: $fineGranted, 粗略位置: $coarseGranted")

        if (!fineGranted && !coarseGranted) {
            Log.e(TAG, "位置权限未授予")
            result.error("PERMISSION_DENIED", "位置权限未授予", null)
            return
        }

        // 设置超时处理
        setupLocationTimeout(result)

        // 首先尝试获取最后已知位置
        Log.d(TAG, "尝试获取最后已知位置...")
        try {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: Location? ->
                    if (location != null) {
                        val ageMs = System.currentTimeMillis() - location.time
                        val isValid = ageMs < 5 * 60 * 1000
                        Log.d(TAG, "获取到最后已知位置:")
                        Log.d(TAG, "  纬度: ${location.latitude}")
                        Log.d(TAG, "  经度: ${location.longitude}")
                        Log.d(TAG, "  精度: ${location.accuracy} 米")
                        Log.d(TAG, "  时间: ${formatTime(location.time)}")
                        Log.d(TAG, "  数据年龄: ${ageMs / 1000} 秒")
                        Log.d(TAG, "  是否有效: $isValid")

                        if (isLocationValid(location)) {
                            Log.d(TAG, "使用缓存位置")
                            cancelTimeout()
                            result.success(createLocationMap(location))
                        } else {
                            Log.d(TAG, "缓存位置过期，请求新位置")
                            requestNewLocation(result)
                        }
                    } else {
                        Log.d(TAG, "没有缓存位置，请求新位置")
                        requestNewLocation(result)
                    }
                }
                .addOnFailureListener { exception ->
                    Log.e(TAG, "获取最后已知位置失败: ${exception.message}")
                    cancelTimeout()
                    result.error("LOCATION_ERROR", "获取最后已知位置失败: ${exception.message}", null)
                }
        } catch (e: SecurityException) {
            Log.e(TAG, "安全异常: ${e.message}")
            cancelTimeout()
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    /**
     * 检查位置是否有效（不要太旧）
     */
    private fun isLocationValid(location: Location): Boolean {
        val ageMs = System.currentTimeMillis() - location.time
        // 位置数据不超过 5 分钟
        return ageMs < 5 * 60 * 1000
    }

    /**
     * 设置定位超时
     */
    private fun setupLocationTimeout(result: MethodChannel.Result) {
        cancelTimeout()
        Log.d(TAG, "设置定位超时: ${LOCATION_TIMEOUT_MS}ms")
        timeoutRunnable = Runnable {
            Log.e(TAG, "!!! 定位超时 !!!")
            // 超时，移除位置更新回调
            locationCallback?.let {
                fusedLocationClient.removeLocationUpdates(it)
            }
            locationCallback = null
            result.error("LOCATION_TIMEOUT", "获取位置超时，请检查GPS是否开启", null)
        }
        timeoutRunnable?.let {
            handler.postDelayed(it, LOCATION_TIMEOUT_MS)
        }
    }

    /**
     * 取消超时
     */
    private fun cancelTimeout() {
        timeoutRunnable?.let {
            handler.removeCallbacks(it)
        }
        timeoutRunnable = null
    }

    /**
     * 请求新的位置数据
     * 当缓存位置为空时调用
     */
    private fun requestNewLocation(result: MethodChannel.Result) {
        Log.d(TAG, "=== 开始请求新位置 ===")

        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "权限未授予，无法请求新位置")
            cancelTimeout()
            result.error("PERMISSION_DENIED", "位置权限未授予", null)
            return
        }

        // 创建位置请求
        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            10000L
        )
            .setMinUpdateIntervalMillis(5000L)
            .setMaxUpdates(1)
            .setWaitForAccurateLocation(true) // 等待准确位置
            .build()

        Log.d(TAG, "位置请求配置:")
        Log.d(TAG, "  优先级: HIGH_ACCURACY")
        Log.d(TAG, "  间隔: 10000ms")
        Log.d(TAG, "  最小更新间隔: 5000ms")
        Log.d(TAG, "  最大更新次数: 1")

        // 创建位置回调
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                Log.d(TAG, "=== 收到位置更新 ===")
                cancelTimeout()
                locationResult.lastLocation?.let { location ->
                    Log.d(TAG, "位置信息:")
                    Log.d(TAG, "  纬度: ${location.latitude}")
                    Log.d(TAG, "  经度: ${location.longitude}")
                    Log.d(TAG, "  精度: ${location.accuracy} 米")
                    Log.d(TAG, "  海拔: ${location.altitude} 米")
                    Log.d(TAG, "  速度: ${location.speed} m/s")
                    Log.d(TAG, "  方向: ${location.bearing} 度")
                    Log.d(TAG, "  时间: ${formatTime(location.time)}")
                    Log.d(TAG, "  提供者: ${location.provider}")
                    result.success(createLocationMap(location))
                } ?: run {
                    Log.e(TAG, "位置结果为 null")
                    result.error("LOCATION_ERROR", "无法获取位置信息", null)
                }
                // 移除回调
                locationCallback?.let {
                    fusedLocationClient.removeLocationUpdates(it)
                }
                locationCallback = null
            }

            override fun onLocationAvailability(availability: LocationAvailability) {
                Log.d(TAG, "位置可用性变化: ${availability.isLocationAvailable}")
                if (!availability.isLocationAvailable) {
                    Log.w(TAG, "位置当前不可用，继续等待...")
                }
            }
        }

        try {
            Log.d(TAG, "开始请求位置更新...")
            locationCallback?.let {
                fusedLocationClient.requestLocationUpdates(
                    locationRequest,
                    it,
                    Looper.getMainLooper()
                )
            }
        } catch (exception: SecurityException) {
            Log.e(TAG, "请求位置更新时发生安全异常: ${exception.message}")
            cancelTimeout()
            result.error("SECURITY_EXCEPTION", exception.message, null)
        }
    }

    /**
     * 创建位置数据Map，用于传递给Flutter
     */
    private fun createLocationMap(location: Location): Map<String, Any> {
        return mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy,
            "altitude" to (location.altitude.takeIf { it != 0.0 } ?: 0.0),
            "speed" to location.speed,
            "bearing" to location.bearing,
            "time" to location.time
        )
    }

    /**
     * 格式化时间戳
     */
    private fun formatTime(timeMillis: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return sdf.format(Date(timeMillis))
    }

    /**
     * Activity 销毁时清理资源
     */
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "MainActivity 销毁，清理资源")
        cancelTimeout()
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
        locationCallback = null
    }
}
