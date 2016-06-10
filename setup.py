#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.extension import Extension

try:
    from Cython.Build import cythonize
    ext_modules = cythonize([Extension("pymspack", ["src/pymspack.pyx"], libraries=["mspack"])])
except ImportError:
    ext_modules = []


with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = [
    # TODO: put package requirements here
]

test_requirements = [
    'pytest'
]

setup(
    name='pymspack',
    version='0.1.1',
    description="Python bindings to libmspack",
    long_description=readme + '\n\n' + history,
    author="Gaetan Crahay",
    author_email='gaetan@crahay.eu',
    url='https://github.com/gcrahay/pymspack',
    include_package_data=True,
    install_requires=requirements,
    license="BSD license",
    zip_safe=False,
    keywords='pymspack',
    setup_requires=['Cython', ],
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        "Programming Language :: Python :: 2",
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
    ],
    test_suite='tests',
    tests_require=test_requirements,
    ext_modules=ext_modules
)
