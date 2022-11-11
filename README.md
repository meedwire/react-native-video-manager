# react-native-video-manager

Package for manager video

## Installation

```sh
yarn add react-native-video-manager
```

## Usage

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

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
