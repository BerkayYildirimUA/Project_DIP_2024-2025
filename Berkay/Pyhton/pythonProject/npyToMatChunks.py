#!/usr/bin/env python

import sys
import scipy.io
import numpy as np
import os

FOLDER = 'project'


def npy_to_matlab(name):
    path = "/"

    npyFiles = []
    matStructure = {}

    for f in files:
        extension = os.path.splitext(f)[1]
        if extension == '.npy':
            npyFiles.append(f)

    if not npyFiles:
        print
        "Error: There are no .npy files in %s folder" % (FOLDER)
        sys.exit(0)

    for f in npyFiles:
        currentFile = os.path.join(path, f)
        variable = os.path.splitext(f)[0]

        # MATLAB only loads variables that start with normal characters
        variable = variable.lstrip('0123456789.-_ ')

        try:
            values = np.load(currentFile)
            # Handle large array sizes by saving in chunks
            if values.nbytes > 2e9:  # Approx. 2GB
                print("Large array detected. Saving in chunks.")
                for i, chunk in enumerate(np.array_split(values, 10)):
                    filename_chunk = name + 'chunk_'+ str(i) + '.mat'
                    filesave = os.path.join(path, filename_chunk)
                    scipy.io.savemat(filesave, {'video_data': chunk})
            else:
                filename = name + '.mat'
                filesave = os.path.join(path, filename)
                if matStructure:
                    scipy.io.savemat(filesave, matStructure)
        except IOError:
            print
            "Error: can\'t find file or read data"

        else:
            matStructure[variable] = values




def printUsage():
    print
    "Usage: python %s output_filename " % (sys.argv[0])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        printUsage()
        sys.exit(0)

    if not os.path.exists(FOLDER):
        os.makedirs(FOLDER)

    filename = str(sys.argv[1])
    npy_to_matlab(filename)