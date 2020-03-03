#cython: language_level=3
cdef extern from "mspack.h":
    cdef struct mscab_decompressor:
        mscabd_cabinet * (*open) (mscab_decompressor *self, const char *filename)
        void (*close)(mscab_decompressor *self, mscabd_cabinet *cab)
        int(*extract)(mscab_decompressor *self, mscabd_file *file, const char *filename)
        int(*last_error)(mscab_decompressor *self)
    cdef struct mscabd_cabinet:
        const char *filename
        unsigned int length
        mscabd_file *files
        mscabd_folder *folders
    cdef struct mscabd_file:
        mscabd_file *next
        char *filename
        unsigned int length
        char time_h
        char time_m
        char time_s
        char date_d
        char date_m
        int date_y
        int attribs
    cdef struct mscabd_folder:
        mscabd_folder *next
    cdef struct mspack_system:
        pass

    cdef const int MSCAB_ATTRIB_RDONLY
    cdef const int MSCAB_ATTRIB_HIDDEN
    cdef const int MSCAB_ATTRIB_SYSTEM
    cdef const int MSCAB_ATTRIB_ARCH
    cdef const int MSCAB_ATTRIB_EXEC
    cdef const int MSCAB_ATTRIB_UTF_NAME

    cdef const int MSPACK_ERR_OK
    cdef const int MSPACK_ERR_ARGS
    cdef const int MSPACK_ERR_OPEN
    cdef const int MSPACK_ERR_READ
    cdef const int MSPACK_ERR_WRITE
    cdef const int MSPACK_ERR_SEEK
    cdef const int MSPACK_ERR_NOMEMORY
    cdef const int MSPACK_ERR_SIGNATURE
    cdef const int MSPACK_ERR_DATAFORMAT
    cdef const int MSPACK_ERR_CHECKSUM
    cdef const int MSPACK_ERR_CRUNCH
    cdef const int MSPACK_ERR_DECRUNCH

    void MSPACK_SYS_SELFTEST(int)

    mscab_decompressor *mspack_create_cab_decompressor(mspack_system *sys)
    void mspack_destroy_cab_decompressor(mscab_decompressor *self)
