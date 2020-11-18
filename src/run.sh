datadir=/project/new_data # Directory where the speech data is stored
wanted_words_list='busagent,hellobus,okagent,okbus'
# datadir structure is as follows:
# new_data/
# |-- BusAgent
# |-- HelloBus
# |-- OkAgent
# |-- OkBus
# |-- _background_noise_

#python train.py --wanted_words=${wanted_words_list} --data_dir=${datadir} -batch_size=20 --save_step_interval=50 --how_many_training_steps=400,100
#
#
#python freeze.py \
#--start_checkpoint=tmp/speech_commands_train/conv.ckpt-500 \
#--output_file=tmp/my_frozen_graph.pb \
#--wanted_words=busagent,hellobus,okagent,okbus
#
#
#python label_wav.py \
#--graph=tmp/my_frozen_graph.pb \
#--labels=tmp/speech_commands_train/conv_labels.txt \
#--wanted_words=busagent,hellobus,okagent,okbus \
#--wav=/home/adminnus/Documents/Database/data_speech_commands_v0.02/busagent/BusAgent3min_16k-45.wav
#
#
#
#tflite_convert \
#    --output_file=/tmp/retrained_graph.tflite \
#    --graph_def_file=/tmp/retrained_graph.pb \
#    --input_arrays=input \
#    --output_arrays=output



###################################################################################
#  1400ms duration for yesno data 10 classes
# #################################################################################  
#
# /home/maulik/anaconda3/bin/python3 freeze.py \
# --start_checkpoint=tmp/speech_commands_train/conv.ckpt-18000 \
# --output_file=tmp/speech_commands_train/my_frozen_graph.pb --clip_duration_ms=1400


# /home/maulik/anaconda3/bin/python3 label_wav.py \
# --graph=tmp/speech_commands_train/my_frozen_graph.pb \
# --labels=tmp/speech_commands_train/conv_labels.txt \
# --wav=/home/maulik/Documents/Database/data_speech_commands_v0.02/right/0ab3b47d_nohash_0.wav


# tflite_convert \
#     --output_file=tmp/speech_commands_train/retrained_graph.tflite \
#     --graph_def_file=tmp/speech_commands_train/my_frozen_graph.pb \
#     --input_arrays=decoded_sample_data,decoded_sample_data:1 \
#     --output_arrays=labels_softmax --allow_custom_ops
    
#####################################################################################    

# ! careful ! small examples for wanted words
# python train.py --wanted_words=${wanted_words_list} --data_dir=${datadir} -batch_size=20 --save_step_interval=50 --how_many_training_steps=400,100

#python pretrained_pb2npz.py

# Freeze the model parameter and change the last layer
python transfer.py

# Convert model into protobuffer
python freeze.py \
--start_checkpoint=/project/tmp/speech_commands_train_transfer/conv.ckpt-300 \
--output_file=/project/tmp/speech_commands_train_transfer/my_frozen_graph.pb \
--wanted_words=busagent,hellobus,okagent,okbus \
--clip_duration_ms=800

# Do quick test 
python label_wav.py \
--graph=/project/tmp/speech_commands_train_transfer/my_frozen_graph.pb \
--labels=/project/tmp/speech_commands_train_transfer/conv_labels.txt \
--wanted_words=busagent,hellobus,okagent,okbus \
--wav=${datadir}/busagent/BusAgent3min_16k-05.wav

# tflite_convert \
#     --output_file=tmp/speech_commands_train_transfer/retrained_graph.tflite \
#     --graph_def_file=tmp/speech_commands_train_transfer/my_frozen_graph.pb \
#     --input_arrays=decoded_sample_data \
#     --output_arrays=labels_softmax --allow_custom_ops


tflite_convert \
    --output_file=/project/tmp/speech_commands_train_transfer/retrained_graph.tflite \
    --graph_def_file=/project/tmp/speech_commands_train_transfer/my_frozen_graph.pb \
    --input_arrays=decoded_sample_data,decoded_sample_data:1 \
    --output_arrays=labels_softmax --allow_custom_ops
