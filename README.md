# Wakeword Detection (Hellobus)

A speech recognition system for detecting custom wakewords using TensorFlow transfer learning and TensorFlow Lite for mobile deployment.

For more information, see the [TensorFlow audio recognition tutorial](https://www.tensorflow.org/tutorials/sequences/audio_recognition).

## Requirements

- `tensorflow==1.15.0`
- Optional: [Speech Commands dataset](https://www.tensorflow.org/datasets/catalog/speech_commands) (only needed to retrain from scratch)

## Data Setup

In the `run.sh` file, configure the data directory and target words:

```bash
datadir=new_data  # Directory where the speech data is stored
wanted_words_list='busagent,hellobus,okagent,okbus'
```

The data directory must follow this structure:

```
new_data/
 |-- busagent
 |-- hellobus
 |-- okagent
 |-- okbus
 |-- _background_noise_
```

Record audio samples and place them in the corresponding folders. The `_background_noise_` folder contains audio that does not belong to any wakeword class.

## Training Process

Run the full pipeline using `run.sh`:

1. Load pretrained model weights — `pretrained_pb2npz.py`
2. Run transfer learning — `utils/transfer.py`
3. Freeze the model to protobuffer format — `utils/freeze.py`
4. Run a quick inference test — `utils/label_wav.py`
5. Convert to TensorFlow Lite — `tflite_convert`

## Running with Docker

**Build the container:**
```bash
docker build . -t wakeup
```

**Run training inside the container:**

1. Start the container with a bash entrypoint:
```bash
docker run -it wakeup bash
```

2. Inside the container, run the pipeline:
```bash
./run.sh
```

## Large File Storage

This repository uses [Git LFS](https://git-lfs.github.com/) to track large binary files (`.pb`, `.tflite`, `.npz`, `.ckpt`). Ensure Git LFS is installed before cloning:

```bash
git lfs install
git clone <repo-url>
```
