package com.reactnativevideomanager;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = VideoManagerModule.NAME)
public class VideoManagerModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VideoManager";
    private final VideoManager videoManager = new VideoManager(this.getReactApplicationContext());

    public VideoManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    public void getFramesVideo(String source, ReadableMap options, Promise promise) {
      videoManager.getVideoFrames(source, options, promise);
    }

    @ReactMethod
    public void getVideoInfo(String source, Promise promise) {
      videoManager.getVideoInfo(source, promise);
    }

    @ReactMethod
    public void compress(String source, ReadableMap options, Promise promise) {
      videoManager.compress(source, options, promise);
    }
}
