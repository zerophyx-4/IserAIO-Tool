package com.hsr.isertoolkit

private const val SYSTEM_PROPERTIES_CLASS = "android.os.SystemProperties"

object SystemPropsHelper {
    private val systemPropertiesClass: Class<*>? = try {
        Class.forName(SYSTEM_PROPERTIES_CLASS)
    } catch (e: Exception) {
        null
    }

    private val getMethod by lazy {
        systemPropertiesClass?.getMethod("get", String::class.java, String::class.java)
    }

    private val setMethod by lazy {
        systemPropertiesClass?.getMethod("set", String::class.java, String::class.java)
    }

    fun get(key: String, default_: String): String {
        return try {
            getMethod?.invoke(null, key, default_) as? String ?: default_
        } catch (e: Exception) {
            default_
        }
    }

    fun set(key: String, value: String): Boolean {
        return try {
            setMethod?.invoke(null, key, value)
            true
        } catch (e: Exception) {
            false
        }
    }
}