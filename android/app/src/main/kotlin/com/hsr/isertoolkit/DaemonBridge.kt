package com.hsr.isertoolkit

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter
import java.net.Socket
import java.io.File

object DaemonBridge {
    private const val SOCKET_PATH = "/dev/socket/hsr_daemon"

    fun send(command: String): String {
        return try {
            val socket = LocalSocketClient.connect(SOCKET_PATH)
            socket.write(command)
            val resp = socket.read()
            socket.close()
            resp
        } catch (e: Exception) {
            "FAIL:${e.message}"
        }
    }
}