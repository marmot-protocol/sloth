package io.crates.keyring

import android.content.Context

class Keyring {
    companion object {
        init {
            System.loadLibrary("rust_lib_whitenoise")
        }

        external fun initializeNdkContext(context: Context)
    }
}
