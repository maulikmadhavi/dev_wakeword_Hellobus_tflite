import tensorflow as tf
from tensorflow.python.platform import gfile
import numpy as np


GRAPH_PB_PATH = 'tmp/pretrained_model/conv_actions_frozen.pb'
# GRAPH_PB_PATH = 'tmp/speech_commands_train/my_frozen_graph.pb'
with tf.Session() as sess:
   print("load graph")
   with gfile.FastGFile(GRAPH_PB_PATH,'rb') as f:
       graph_def = tf.GraphDef()
   graph_def.ParseFromString(f.read())
   sess.graph.as_default()
   tf.import_graph_def(graph_def, name='')
   graph_nodes=[n for n in graph_def.node]
   names = []
   for t in graph_nodes:
      names.append(t.name)
   print(names)



def create_graph(modelFullPath):
    """Creates a graph from saved GraphDef file and returns a saver."""
    # Creates graph from saved graph_def.pb.
    with tf.gfile.FastGFile(modelFullPath, 'rb') as f:
        graph_def = tf.GraphDef()
        graph_def.ParseFromString(f.read())
        tf.import_graph_def(graph_def, name='')
create_graph(GRAPH_PB_PATH)

constant_values = {}

with tf.Session() as sess:
  constant_ops = [op for op in sess.graph.get_operations() if op.type == "Const"]
  for constant_op in constant_ops:
    constant_values[constant_op.name] = sess.run(constant_op.outputs[0])
    print('name: {} \t shape: {}'.format(constant_op,constant_values[constant_op.name].shape))

w1np = constant_values['Variable']
b1np = constant_values['Variable_1']
w2np = constant_values['Variable_2']
b2np = constant_values['Variable_3']

np.savez('tmp/pretrained_model/pretrained_numpy_weights.npz', w1np, b1np, w2np, b2np)

