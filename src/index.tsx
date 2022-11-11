import React from 'react';
import {
  NativeModules,
  Platform,
  requireNativeComponent,
  ViewProps,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-video-manager' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const VideoManager = NativeModules.VideoManager
  ? NativeModules.VideoManager
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

interface IOptionsGetFrames {
  /**
   * @property {number} totalFrames default value is 10
   */
  totalFrames?: number;
  /**
   * @property {number} width default value is 200
   */
  width?: number;
  /**
   * @property {number} height default value is relative to width
   */
  height?: number;
}

export function getFramesVideo(
  source: string,
  options?: IOptionsGetFrames
): Promise<string[]> {
  return VideoManager.getFramesVideo(source, options ?? {});
}

export interface IVideoInfo {
  /**
   * @property {number} duration value in milliseconds
   */
  duration: number;
}

export function getVideoInfo(source: string): Promise<IVideoInfo> {
  return VideoManager.getVideoInfo(source);
}

export interface IVideoCompress {
  filePath: string;
  fileSize: number;
  originalFileSize: number;
}

export function compress(
  source: string,
  options?: any
): Promise<IVideoCompress> {
  return VideoManager.compress(source, options ?? {});
}

export interface IOptionsCropVideo {
  /**
   * @property {number} startTime value in seconds
   */
  startTime: number;
  /**
   * @property {number} endTime value in seconds
   */
  endTime: number;
}

export function cropVideo(
  source: string,
  options: IOptionsCropVideo
): Promise<string> {
  return VideoManager.cropVideo(source, options);
}

interface IPropsVideo extends ViewProps {
  source?: string;
}

const RTCVideo = requireNativeComponent<IPropsVideo>('VideoView');

export const Video: React.FC<IPropsVideo> = ({ ...props }) => {
  return React.createElement<IPropsVideo>(RTCVideo as any, { ...props });
};
