package com.turkradyo.bsr.de.turkradyo

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Base64
import java.io.File
import java.io.FileOutputStream

class ArtworkProvider : ContentProvider() {
    override fun onCreate(): Boolean = true

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        val file = resolveFile(uri)
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun getType(uri: Uri): String {
        val path = uri.path ?: return "image/png"
        return when {
            path.endsWith(".jpg", true) || path.endsWith(".jpeg", true) -> "image/jpeg"
            else -> "image/png"
        }
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?
    ): Int = 0

    private fun resolveFile(uri: Uri): File {
        val segments = uri.pathSegments
        require(segments.size >= 2) { "Invalid artwork URI" }

        return when (segments[0]) {
            "file" -> {
                val decodedPath = String(
                    Base64.decode(segments[1], Base64.URL_SAFE or Base64.NO_WRAP),
                    Charsets.UTF_8
                )
                val file = File(decodedPath).canonicalFile
                val cacheDir = context!!.cacheDir.canonicalFile
                val filesDir = context!!.filesDir.canonicalFile
                require(file.path.startsWith(cacheDir.path) || file.path.startsWith(filesDir.path)) {
                    "Artwork path is outside app storage"
                }
                require(file.exists()) { "Artwork file not found" }
                file
            }
            "avatar" -> avatarFile(segments[1].take(1).uppercase())
            else -> throw IllegalArgumentException("Unknown artwork URI type")
        }
    }

    private fun avatarFile(letter: String): File {
        val safeLetter = if (letter.matches(Regex("[A-Z]"))) letter else "#"
        val file = File(context!!.cacheDir, "aa_provider_avatar_$safeLetter.png")
        if (!file.exists()) {
            generateAvatar(safeLetter, file)
        }
        return file
    }

    private fun generateAvatar(letter: String, file: File) {
        val size = 256
        val palette = intArrayOf(
            Color.rgb(124, 58, 237),
            Color.rgb(37, 99, 235),
            Color.rgb(5, 150, 105),
            Color.rgb(217, 119, 6),
            Color.rgb(220, 38, 38),
            Color.rgb(8, 145, 178),
            Color.rgb(101, 163, 13),
            Color.rgb(225, 29, 72)
        )
        val colorIndex = (if (letter == "#") 35 else letter[0].code) % palette.size
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val bg = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = palette[colorIndex]
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, bg)

        val highlight = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(45, 255, 255, 255)
        }
        canvas.drawCircle(size * 0.35f, size * 0.30f, size * 0.42f, highlight)

        val text = if (letter == "#") "\u266A" else letter
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            textSize = size * 0.52f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        val bounds = Rect()
        textPaint.getTextBounds(text, 0, text.length, bounds)
        canvas.drawText(text, size / 2f, size / 2f - bounds.exactCenterY(), textPaint)

        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
        bitmap.recycle()
    }
}
