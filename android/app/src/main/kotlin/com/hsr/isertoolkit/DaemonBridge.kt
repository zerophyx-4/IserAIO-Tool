package com.hsr.isertoolkit

object DaemonBridge {
    private const val SOCKET_PATH = "/dev/socket/hsr_daemon"

    fun send(command: String): String {
        return try {
            val client = LocalSocketClient.connect(SOCKET_PATH)
            client.write(command)
            val resp = client.read()
            client.close()
            resp
        } catch (e: Exception) {
            "FAIL:${e.message}"
        }
    }
}