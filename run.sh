datadir=/home/maulik/Documents/Database/data_speech_commands_v0.02/new_data # Directory where the data is stores
wanted_words_list='busagent,hellobus,okagent,okbus'


# ! careful ! small examples for wanted words

# Perform training on the google speech commad dataset 
python utils/train.py  -batch_size=20 --save_step_interval=50 --how_many_training_steps=400,100

# To obtain convolutional nn parameters in numpy format
python pretrained_pb2npz.py 

# To perfrom the transfer learning 
python transfer.py

# Freeze the parameters 
python utils/freeze.py \
--start_checkpoint=models/speech_commands_train_transfer/conv.ckpt-300 \
--output_file=models/speech_commands_train_transfer/my_frozen_graph.pb \
--wanted_words=busagent,hellobus,okagent,okbus \
--clip_duration_ms=800

# Simply check whether the model makes sense
python utils/label_wav.py \
--graph=models/speech_commands_train_transfer/my_frozen_graph.pb \
--labels=models/speech_commands_train_transfer/conv_labels.txt \
--wanted_words=busagent,hellobus,okagent,okbus \
--wav=${datadir}/BusAgent/BusAgent3min_16k-45.wav

# Convert to tflite
tflite_convert \
    --output_file=models/speech_commands_train_transfer/retrained_graph.tflite \
    --graph_def_file=models/speech_commands_train_transfer/my_frozen_graph.pb \
    --input_arrays=decoded_sample_data,decoded_sample_data:1 \
    --output_arrays=labels_softmax --allow_custom_ops
