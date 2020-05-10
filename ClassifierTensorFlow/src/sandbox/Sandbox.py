import subprocess
import tempfile
from shlex import shlex
from subprocess import call
import os

# print(subprocess.check_output(['/Users/jonathanduss/Desktop/ArticlePreprocessorTool']), os.getcwd())

(file, path) = tempfile.mkstemp()
print(file)
print(path)

process = subprocess.Popen(["./ArticlePreprocessorTool", '/Users/jonathanduss/Desktop/untitled folder/articles_fr_28.json', '/Users/jonathanduss/Desktop/untitled folder/articles_fr_28_out.json'], stdout=subprocess.PIPE)
while True:
    p = process.poll()
    output = process.stdout.readline()
    if process.poll() is not None:
        break
    if output:
        print(output.strip())

