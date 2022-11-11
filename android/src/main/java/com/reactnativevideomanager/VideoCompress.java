package com.reactnativevideomanager;

import android.content.Context;
import android.net.Uri;

import com.facebook.react.bridge.Promise;


public class VideoCompress {
  Uri uriFile;
  Context reactContext;
  Promise promise;

  VideoCompress(String source, Context context, Promise promise){
    this.uriFile = Uri.parse(source);
    this.reactContext = context;
    this.promise = promise;
  }

  public void compress(){}
}
