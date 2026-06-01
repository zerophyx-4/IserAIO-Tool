package com.hsr.isertoolkit

import android.net.LocalSocket
import android.net.LocalSocketAddress
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter

class LocalSocketClient private constructor(private val socket: LocalSocket) {

    companion object {
        fun connect(path: String): LocalSocketClient {
            val socket = LocalSocket()
            socket.connect(LocalSocketAddress(path, LocalSocketAddress.Namespace.FILESYSTEM))
            socket.soTimeout = 3000
            return LocalSocketClient(socket)
        }
    }

    fun write(data: String) {
        val writer = PrintWriter(socket.outputStream)
        writer.println(data)
        writer.flush()
    }

    fun read(): String {
        val reader = BufferedReader(InputStreamReader(socket.inputStream))
        return reader.readLine() ?: "FAIL"
    }

    fun close() {
        socket.close()
    }
}