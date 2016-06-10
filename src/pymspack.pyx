cimport pymspack
import os.path

__version__ = "0.1.0"

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
    cdef pymspack.mscab_decompressor *_c_cab_decompressor
    cdef pymspack.mscabd_cabinet *_c_cabd_cabinet

    def __cinit__(self):
        result = 1
        pymspack.MSPACK_SYS_SELFTEST(result)
        if result != MSPACK_ERR_OK:
            raise Exception("libmspack cannot be used on your system")
        self._c_cab_decompressor = pymspack.mspack_create_cab_decompressor(NULL)
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
            infos.append(CabInfo(file_struct.filename, file_struct.length, (
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
            if not os.path.isdir(path):
                raise Exception("Directory '{}' doesn't exist".format(path))
            destination = os.path.join(path, destination)
        if isinstance(file_or_info, CabInfo):
            file_or_info = file_or_info.filename
        file_struct = self._c_cabd_cabinet.files
        while file_struct is not NULL:
            if file_or_info == file_struct.filename:
                ret = self._c_cab_decompressor.extract(self._c_cab_decompressor, file_struct, destination)
                if ret == pymspack.MSPACK_ERR_OK:
                    return True
                raise Exception("Error extracting '{}' ({})".format(file_or_info, ret))
            file_struct = file_struct.next
        raise Exception("File '{}' not in the CAB file".format(file_or_info))

    def _must_be_open(self):
        if self._c_cab_decompressor is NULL:
            raise Exception('CAB decompressor is not ready')
        if self._c_cabd_cabinet is NULL:
            raise Exception('CAB file must be open')


    def __dealloc__(self):
        if self._c_cab_decompressor is not NULL:
            self.close()
            pymspack.mspack_destroy_cab_decompressor(self._c_cab_decompressor)
            self._c_cab_decompressor = NULL

