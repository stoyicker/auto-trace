package root

import android.app.Activity
import android.os.Bundle
import android.util.Log

internal class MainActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    Log.d("FromSource", "savedInstanceState: $savedInstanceState")
  }
}
