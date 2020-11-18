# Speech Commands Example

This is a basic speech recognition example. For more information, see the
tutorial at https://www.tensorflow.org/tutorials/sequences/audio_recognition


# Requirements
tensorflow==1.15.0
Optional: speech command database (If you want to train again, https://www.tensorflow.org/datasets/catalog/speech_commands)

In `run.sh` file:
```
datadir=new_data # Directory where the speech data is stored
wanted_words_list='busagent,hellobus,okagent,okbus'
```

 These two lines indicate directory and wanted words. The directory has 

``` 
new_data/
 |-- busagent
 |-- hellobus
 |-- okagent
 |-- okbus
 |-- _background_noise_
```

# Process

use `run.sh`



1. Load pretrained model `pretrained_pb2npz.py`
2. Run the transfer learning `transfer.py`
3. Convert back to protobuffer `freeze.py `
4. Do quick test 
5. Convert to tflite

