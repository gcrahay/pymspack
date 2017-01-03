#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
test_pymspack
----------------------------------

Tests for `pymspack` module.
"""

import pymspack
import tempfile

def test_module():
    assert pymspack


def test_cabfile():
    cab = pymspack.CabFile()
    assert cab


def test_infolist():
    import os.path
    cab = pymspack.CabFile(os.path.join(os.path.dirname(__file__), 'data', '000.cab'))
    infos = cab.infolist()
    assert isinstance(infos, list)
    assert len(infos) == 4
    for info in infos:
        assert isinstance(info, pymspack.CabInfo)
        assert isinstance(info.date_time, tuple)
        assert len(info.date_time) == 6
        assert info.file_size > 0
    cab.close()


def test_extract():
    import os.path
    import hashlib
    import shutil
    cab = pymspack.CabFile(os.path.join(os.path.dirname(__file__), 'data', '000.cab'))
    temp_dir = None
    try:
        temp_dir = tempfile.mkdtemp()
        assert os.path.exists(temp_dir)
        cab.extract('WERInternalMetadata.xml', os.path.join(temp_dir, 'WERInternalMetadata.xml'))
        h = hashlib.new('md5')
        with open(os.path.join(temp_dir, 'WERInternalMetadata.xml'), 'rb') as f:
            h.update(f.read())
    finally:
        if temp_dir and os.path.isdir(temp_dir):
            shutil.rmtree(temp_dir)
    assert h.hexdigest() == '9ed41cedad7b3b3d0a55a4e0cf334323'

    cab.close()

def test_extract_with():
    import os.path
    import hashlib
    import shutil
    with pymspack.CabFile(os.path.join(os.path.dirname(__file__), 'data', '000.cab')) as cab:
        temp_dir = None
        try:
            temp_dir = tempfile.mkdtemp()
            cab.extract('WERInternalMetadata.xml', os.path.join(temp_dir, 'WERInternalMetadata.xml'))
            h = hashlib.new('md5')
            with open(os.path.join(temp_dir, 'WERInternalMetadata.xml'), 'rb') as f:
                h.update(f.read())
        finally:
            if temp_dir and os.path.isdir(temp_dir):
                shutil.rmtree(temp_dir)
        assert h.hexdigest() == '9ed41cedad7b3b3d0a55a4e0cf334323'
