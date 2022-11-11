package com.reactnativevideomanager;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.media.MediaCodec;
import android.media.MediaMetadataRetriever;
import android.net.Uri;

import androidx.core.app.ActivityCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;
import java.util.UUID;

public class VideoManager {
  private static final int REQUEST_EXTERNAL_STORAGE = 1;
  private ReactApplicationContext reactContext;

  VideoManager(ReactApplicationContext context){
    this.reactContext = context;
  }

  private static String[] PERMISSIONS_STORAGE = {
    Manifest.permission.READ_EXTERNAL_STORAGE,
    Manifest.permission.WRITE_EXTERNAL_STORAGE
  };

  private void requestPermission(){
    Activity activity = Objects.requireNonNull(reactContext.getCurrentActivity());

    int permission = ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE);

    if (permission != PackageManager.PERMISSION_GRANTED){
      ActivityCompat.requestPermissions(
        activity,
        PERMISSIONS_STORAGE,
        REQUEST_EXTERNAL_STORAGE
      );
    }
  }

  public void getVideoFrames(String source, ReadableMap options, Promise promise){
    WritableArray images = Arguments.createArray();

    Uri videoUri = Uri.parse(source);

    File videoFile = new File(videoUri.getPath());
    MediaMetadataRetriever retriever = new MediaMetadataRetriever();

    this.requestPermission();

    boolean fileExists = videoFile.exists();

    if (!fileExists){
      promise.reject(new Error("File video not exists"));
      return;
    }

    retriever.setDataSource(videoUri.getPath());

    long duration = Long.parseLong(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
    int width = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
    int height = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
    int orientation = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION));

    float aspectRatio = (float)width / (float)height;

    int resizeWidth = 200;
    int resizeHeight = Math.round(resizeWidth / aspectRatio);

    float scaleWidth = ((float) resizeWidth) / width;
    float scaleHeight = ((float) resizeHeight) / height;

    for (long i = 0; i < (duration * 1000); i += (duration * 1000) / 10) {
      Bitmap frame = null;
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
        frame = retriever.getScaledFrameAtTime(i, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, resizeWidth, resizeHeight);
      }

      if (frame == null) {
        continue;
      }

      String frameName = UUID.randomUUID().toString().concat(".jpg");

      String pathFrame = reactContext.getCacheDir().getPath().concat("/").concat(frameName);

      File frameFile = new File(pathFrame);

      ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
      frame.compress(Bitmap.CompressFormat.PNG, 90, byteArrayOutputStream);

      FileOutputStream fileOutputStream = null;
      try {
        fileOutputStream = new FileOutputStream(frameFile);
      } catch (FileNotFoundException e) {
        promise.reject(new Error("Failed create outputream to file"));
        e.printStackTrace();
        return;
      }

      try {
        fileOutputStream.write(byteArrayOutputStream.toByteArray());
      } catch (IOException e) {
        promise.reject(new Error("Failed write bytes"));
        e.printStackTrace();
        return;
      }

      try {
        fileOutputStream.close();
      } catch (IOException e) {
        e.printStackTrace();
        promise.reject(new Error("Failed close fileOutputStream"));
        return;
      }

      images.pushString(frameFile.toURI().toString());
    }

    promise.resolve(images);
  }

  public void getVideoInfo(String source, Promise promise){
    Uri videoUri = Uri.parse(source);

    File videoFile = new File(videoUri.getPath());
    MediaMetadataRetriever retriever = new MediaMetadataRetriever();

    boolean fileExists = videoFile.exists();

    if (!fileExists){
      promise.reject(new Error("File video not exists"));
      return;
    }

    retriever.setDataSource(videoUri.getPath());

    long duration = Long.parseLong(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
    int width = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
    int height = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
    int orientation = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION));

    WritableMap videoInfo = Arguments.createMap();

    videoInfo.putString("duration", String.valueOf(duration));

    promise.resolve(videoInfo);
  }

  public void compress(String source, ReadableMap options, Promise promise){
    VideoCompress videoCompress = new VideoCompress(source, reactContext, promise);

    videoCompress.compress();
  }
}
