from setuptools import setup, find_packages
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='block-parser',
    version='1.0.0',
    description='A tool for parsing Windows PowerShell script block logging events',
    long_description=long_description,
    url='https://github.com/matthewdunwoody/block-parser',
    author='Matthew Dunwoody',
    license='Apache Software License',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Information Technology',
        'Topic :: Security',
        'License :: OSI Approved :: Apache Software License',
        'Programming Language :: Python :: 2.7'
    ],

    packages=find_packages(),
    install_requires=['python-evtx', 'lxml'],
    scripts=[path.join(here, 'block-parser', 'block-parser.py')],
)
