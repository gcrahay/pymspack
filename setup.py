#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.extension import Extension

try:
    from Cython.Build import cythonize
    ext_modules = [Extension("pymspack.ext", ["src/ext.c"], libraries=["mspack"])]
except ImportError:
    print("Yous should have Cython installed to build this package extension.")
    import sys
    sys.exit()

if __name__ == "__main__":
    setup(ext_modules=ext_modules)
