# react-native-video-manager

Package for manager video

## Installation

```sh
yarn add react-native-video-manager
```

## Usage - Get frames video

```js
import { getFramesVideo } from 'react-native-video-manager';

// ...

const App: React.FC = () => {
    const [source, setSouce] = useState()

    const getFrames = useCallback(async () => {
        try {
            if (!source) return;

            const frames = await getVideoFrames(source);

            setFrames(frames);
        }catch(e){
            console.error(e)
        }
    }, [source])

    return (
        <View>
            <Button title="Retrieve Frames" onPress={getFrames} />
        <View/>
    )
}
```

## Usage - Compress Video

```js
import { compress } from 'react-native-video-manager';

// ...

const App: React.FC = () => {
    const [source, setSouce] = useState()

    const handleCropVideo = useCallback(async () => {
        try {
            if (!source) return;

            const {
                filePath,
                fileSize,
                originalFileSize
            } = await compress(source);

            setSouce(filePath);
        }catch(e){
            console.error(e)
        }
    }, [source])

    return (
        <View>
            <Button title="Retrieve Frames" onPress={handleCropVideo} />
        <View/>
    )
}
```

## Usage - Crop Video

```js
import { cropVideo } from 'react-native-video-manager';

// ...

const App: React.FC = () => {
    const [source, setSouce] = useState()

    const handleCropVideo = useCallback(async () => {
        try {
            if (!source) return;

            // Seconds
            const startTime = 0;
            // Seconds
            const endTime = 10;

            const source = await cropVideo(source, {startTime, endTime});

            setSouce(source);
        }catch(e){
            console.error(e)
        }
    }, [source])

    return (
        <View>
            <Button title="Retrieve Frames" onPress={handleCropVideo} />
        <View/>
    )
}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
