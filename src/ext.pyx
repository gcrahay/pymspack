cimport ext
from os import path as os_path
__version__ = "0.2.0"

cdef char * _chars(s):
    if isinstance(s, unicode):
        # encode to the specific encoding used inside of the module
        s = (<unicode>s).encode('utf8')
    return s


def test_bit(int_type, offset):
   mask = 1 << offset
   return int_type & mask


class CabInfo:
    def __init__(self, name, size, date, attribs=0):
        self._filename = name
        self.file_size = size
        self.date_time = date
        self._attribs = attribs

    @property
    def filename(self):
        return self._filename


cdef class CabFile:
    cdef ext.mscab_decompressor *_c_cab_decompressor
    cdef ext.mscabd_cabinet *_c_cabd_cabinet

    def __cinit__(self):
        result = 1
        ext.MSPACK_SYS_SELFTEST(result)
        if result != MSPACK_ERR_OK:
            raise Exception("libmspack cannot be used on your system")
        self._c_cab_decompressor = ext.mspack_create_cab_decompressor(NULL)
        if self._c_cab_decompressor is NULL:
            raise Exception('Cannot create underlying CAB decompressor')

    def __init__(self, name=None):
        if name is not None:
            self.open(name)


    def open(self, file_name):
        if self._c_cab_decompressor is NULL:
            raise Exception('CAB decompressor is not ready')
        self._c_cabd_cabinet = self._c_cab_decompressor.open(self._c_cab_decompressor, _chars(file_name))
        if self._c_cabd_cabinet is NULL:
            error = self._c_cab_decompressor.last_error(self._c_cab_decompressor)
            raise Exception("Cannot open {} file ({})".format(file_name, error))

    def close(self):
        if self._c_cab_decompressor is not NULL:
            if self._c_cabd_cabinet is not NULL:
                self._c_cab_decompressor.close(self._c_cab_decompressor, self._c_cabd_cabinet)
                self._c_cabd_cabinet = NULL

    def infolist(self):
        self._must_be_open()
        file_struct = self._c_cabd_cabinet.files
        infos = list()
        while file_struct is not NULL:
            infos.append(CabInfo(file_struct.filename.decode('utf-8'), file_struct.length, (
                file_struct.date_y, int(file_struct.date_m), int(file_struct.date_d),
                int(file_struct.time_h), int(file_struct.time_m), int(file_struct.time_s)
            )))
            file_struct = file_struct.next
        return infos

    def namelist(self):
        self._must_be_open()
        file_struct = self._c_cabd_cabinet.files
        names = list()
        while file_struct is not NULL:
            names.append(file_struct.filename)
            file_struct = file_struct.next
        return names

    def extract(self, file_or_info, destination, path=None):
        self._must_be_open()
        if path is not None:
            if not os_path.isdir(path):
                raise Exception("Directory '{}' doesn't exist".format(path))
            destination = os_path.join(path, destination)
        if isinstance(file_or_info, CabInfo):
            file_or_info = file_or_info.filename
        else:
            file_or_info = _chars(file_or_info)
        file_struct = self._c_cabd_cabinet.files
        while file_struct is not NULL:
            filename = file_struct.filename
            if file_or_info == filename:
                ret = self._c_cab_decompressor.extract(self._c_cab_decompressor, file_struct, _chars(destination))
                if ret == ext.MSPACK_ERR_OK:
                    return True
                print ret
                raise Exception("Error extracting '{}' ({})".format(file_or_info, ret))
            file_struct = file_struct.next
        raise Exception("File '{}' not in the CAB file".format(file_or_info))

    def _must_be_open(self):
        if self._c_cab_decompressor is NULL:
            raise Exception('CAB decompressor is not ready')
        if self._c_cabd_cabinet is NULL:
            raise Exception('CAB file must be open')

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.close()


    def __dealloc__(self):
        if self._c_cab_decompressor is not NULL:
            self.close()
            ext.mspack_destroy_cab_decompressor(self._c_cab_decompressor)
            self._c_cab_decompressor = NULL

