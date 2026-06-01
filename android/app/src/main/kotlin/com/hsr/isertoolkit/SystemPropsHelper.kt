package com.hsr.isertoolkit

object SystemPropsHelper {
    private val systemPropertiesClass = try {
        Class.forName("android.os.SystemProperties")
    } catch (e: Exception) {
        null
    }

    fun get(key: String, default_: String): String {
        return try {
            systemPropertiesClass
                ?.getMethod("get", String::class.java, String::class.java)
                ?.invoke(null, key, default_) as? String
                ?: default_
        } catch (e: Exception) {
            default_
        }
    }

    fun set(key: String, value: String): Boolean {
        return try {
            systemPropertiesClass
                ?.getMethod("set", String::class.java, String::class.java)
                ?.invoke(null, key, value)
            true
        } catch (e: Exception) {
            false
        }
    }
}