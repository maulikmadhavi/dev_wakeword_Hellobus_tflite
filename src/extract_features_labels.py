import os
import tensorflow as tf
from subprocess import Popen, PIPE, DEVNULL

from tensorflow.contrib.framework.python.ops import audio_ops as contrib_audio
from tensorflow.python.ops import io_ops
from tensorflow.python.platform import gfile
from tensorflow.python.util import compat
import pickle
import scipy.io.wavfile
import numpy as np
import tqdm

with open('data/DNN_training/wav2path.pk', 'rb') as handle:
    wav2path = pickle.load(handle)

l = list(wav2path.keys())
sample_rate = 16000
window_size_ms = 25
window_stride_ms = 10
window_size_samples = int(sample_rate * window_size_ms / 1000)
window_stride_samples = int(sample_rate * window_stride_ms / 1000)



aliPdf = 'alipdf.txt'
exp = 'exp/mono_ali_5k'
## Generate pdf indices
Popen(['ali-to-pdf', exp + '/final.mdl',
       'ark:gunzip -c %s/ali.*.gz |' % exp,
       'ark,t:' + aliPdf]).communicate()


def readLabels(aliPdfFile):
    labels = {}
    numFeats = 0
    for line in aliPdfFile:
        line = line.split()
        numFeats += len(line) - 1
        labels[line[0]] = np.array([int(i) for i in line[1:]],
                                      dtype=np.uint16)  ## Increase dtype if dealing with >65536 classes
    return labels, numFeats



## Read labels
with open(aliPdf) as f:
    wav2lab, numFeats = readLabels(f)


numFrames = 0
for var in range(len(l)):
    print(var)
    label = wav2lab[l[var]]
    numFrames += len(label)-10

def accumu(lis):
    total = 0
    for x in lis:
        total += x
        yield total


cumsum_numfrm = list(accumu(numFrames))
cumsum_numfrm.insert(0,0)

# numFrames = [list(wav2lab.values())[var].shape[0]-10 for var in range(5000)]

X = np.memmap('Features.npz', dtype='float32', mode='r+', shape=(cumsum_numfrm[-1],440))
Y = np.memmap('Labels.npz', dtype='int32', mode='r+', shape=(cumsum_numfrm[-1],))

ind = 0
with tf.compat.v1.Session(graph=tf.Graph()) as sess:
    wav_filename_placeholder = tf.compat.v1.placeholder(tf.string, [])
    wav_loader = io_ops.read_file(wav_filename_placeholder)
    for var in range(5000):
        wav_path = wav2path[l[var]]
        label = wav2lab[l[var]]
        desired_samples = scipy.io.wavfile.read(wav2path[l[var]])[1].shape[0] # read wave number of samples
        wav_decoder = contrib_audio.decode_wav(wav_loader, desired_channels=1, desired_samples=desired_samples)
        spectrogram = contrib_audio.audio_spectrogram(
            wav_decoder.audio,
            window_size=window_size_samples,
            stride=window_stride_samples,
            magnitude_squared=True)
        output_ = contrib_audio.mfcc(
            spectrogram,
            wav_decoder.sample_rate,
            dct_coefficient_count=40)
        _, _, mfcc = sess.run(
                [wav_decoder,spectrogram,output_],
                feed_dict={wav_filename_placeholder: wav_path})
        # for r in range(len(label)-10):
        for r in range(numFrames[var]):
            ind = cumsum_numfrm[var]+r
            # print(ind)
            lab = label[r+5]
            feat = mfcc[0][r:r+11].flatten()
            mfc = np.zeros(440)
            mfc[:len(feat)] = feat
            X[ind] = mfc
            Y[ind] = lab
            if cumsum_numfrm[var+1]-1 == ind:
                print("Check that index: {}  == numframes: {}".format(ind,cumsum_numfrm[var+1]-1))
            # ind +=1