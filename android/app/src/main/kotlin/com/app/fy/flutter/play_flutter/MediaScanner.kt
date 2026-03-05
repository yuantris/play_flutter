package com.app.fy.flutter.play_flutter

import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MediaScanner(private val context: Context) {
    companion object {
        private const val CHANNEL = "com.playflutter/media_scanner"
        private const val TAG = "MediaScanner"
        
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val scanner = MediaScanner(context)
            
            Log.d(TAG, "MediaScanner registered with channel: $CHANNEL")
            
            channel.setMethodCallHandler { call, result ->
                Log.d(TAG, "Received method call: ${call.method}")
                when (call.method) {
                    "scanAudioFiles" -> {
                        try {
                            val files = scanner.scanAudioFiles()
                            Log.d(TAG, "Scanned ${files.size} audio files")
                            result.success(files)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error scanning audio files", e)
                            result.error("SCAN_ERROR", e.message, null)
                        }
                    }
                    "scanVideoFiles" -> {
                        try {
                            val files = scanner.scanVideoFiles()
                            Log.d(TAG, "Scanned ${files.size} video files")
                            result.success(files)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error scanning video files", e)
                            result.error("SCAN_ERROR", e.message, null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
    
    fun scanAudioFiles(): List<Map<String, Any?>> {
        val files = mutableListOf<Map<String, Any?>>()
        
        Log.d(TAG, "Starting audio file scan...")
        
        try {
            val projection = arrayOf(
                MediaStore.Audio.Media._ID,
                MediaStore.Audio.Media.TITLE,
                MediaStore.Audio.Media.ARTIST,
                MediaStore.Audio.Media.ALBUM,
                MediaStore.Audio.Media.DURATION,
                MediaStore.Audio.Media.DATA,
                MediaStore.Audio.Media.SIZE,
                MediaStore.Audio.Media.DATE_ADDED,
                MediaStore.Audio.Media.DATE_MODIFIED,
                MediaStore.Audio.Media.ALBUM_ID
            )
            
            val selection = "${MediaStore.Audio.Media.IS_MUSIC} = ?"
            val selectionArgs = arrayOf("1")
            val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"
            
            Log.d(TAG, "Querying MediaStore.Audio.Media.EXTERNAL_CONTENT_URI")
            
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )
            
            if (cursor == null) {
                Log.w(TAG, "Cursor is null, no audio files found or permission denied")
                return files
            }
            
            Log.d(TAG, "Cursor count: ${cursor.count}")
            
            cursor.use {
                val idColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val titleColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
                val artistColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
                val albumColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
                val durationColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
                val dataColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
                val dateAddedColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
                val dateModifiedColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)
                val albumIdColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                
                while (it.moveToNext()) {
                    val id = it.getLong(idColumn)
                    val albumId = it.getLong(albumIdColumn)
                    val title = it.getString(titleColumn) ?: "Unknown"
                    val path = it.getString(dataColumn) ?: ""
                    
                    val albumArtUri = ContentUris.withAppendedId(
                        Uri.parse("content://media/external/audio/albumart"),
                        albumId
                    )
                    
                    val file = mapOf<String, Any?>(
                        "id" to id,
                        "title" to title,
                        "artist" to (it.getString(artistColumn) ?: ""),
                        "album" to (it.getString(albumColumn) ?: ""),
                        "duration" to (it.getLong(durationColumn) ?: 0L),
                        "path" to path,
                        "size" to (it.getLong(sizeColumn) ?: 0L),
                        "dateAdded" to (it.getLong(dateAddedColumn) ?: 0L) * 1000,
                        "dateModified" to (it.getLong(dateModifiedColumn) ?: 0L) * 1000,
                        "albumArt" to albumArtUri.toString()
                    )
                    files.add(file)
                    Log.v(TAG, "Found audio: $title at $path")
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException: Permission denied to access media files", e)
        } catch (e: Exception) {
            Log.e(TAG, "Exception while scanning audio files", e)
        }
        
        Log.d(TAG, "Audio scan complete. Found ${files.size} files")
        return files
    }
    
    fun scanVideoFiles(): List<Map<String, Any?>> {
        val files = mutableListOf<Map<String, Any?>>()
        
        Log.d(TAG, "Starting video file scan...")
        
        try {
            val projection = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.TITLE,
                MediaStore.Video.Media.DURATION,
                MediaStore.Video.Media.DATA,
                MediaStore.Video.Media.SIZE,
                MediaStore.Video.Media.DATE_ADDED,
                MediaStore.Video.Media.DATE_MODIFIED,
                MediaStore.Video.Media.WIDTH,
                MediaStore.Video.Media.HEIGHT
            )
            
            val sortOrder = "${MediaStore.Video.Media.TITLE} ASC"
            
            Log.d(TAG, "Querying MediaStore.Video.Media.EXTERNAL_CONTENT_URI")
            
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                sortOrder
            )
            
            if (cursor == null) {
                Log.w(TAG, "Cursor is null, no video files found or permission denied")
                return files
            }
            
            Log.d(TAG, "Cursor count: ${cursor.count}")
            
            cursor.use {
                val idColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                val titleColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE)
                val durationColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
                val dataColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
                val dateAddedColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED)
                val dateModifiedColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED)
                
                while (it.moveToNext()) {
                    val id = it.getLong(idColumn)
                    val title = it.getString(titleColumn) ?: "Unknown"
                    val path = it.getString(dataColumn) ?: ""
                    
                    val thumbnailUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        ContentUris.withAppendedId(
                            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                            id
                        ).toString()
                    } else {
                        null
                    }
                    
                    val file = mapOf<String, Any?>(
                        "id" to id,
                        "title" to title,
                        "duration" to (it.getLong(durationColumn) ?: 0L),
                        "path" to path,
                        "size" to (it.getLong(sizeColumn) ?: 0L),
                        "dateAdded" to (it.getLong(dateAddedColumn) ?: 0L) * 1000,
                        "dateModified" to (it.getLong(dateModifiedColumn) ?: 0L) * 1000,
                        "thumbnail" to thumbnailUri
                    )
                    files.add(file)
                    Log.v(TAG, "Found video: $title at $path")
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException: Permission denied to access media files", e)
        } catch (e: Exception) {
            Log.e(TAG, "Exception while scanning video files", e)
        }
        
        Log.d(TAG, "Video scan complete. Found ${files.size} files")
        return files
    }
}
