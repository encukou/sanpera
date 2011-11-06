"""Deal with GraphicsMagick errors."""

class GenericMagickException(Exception): pass

cdef class ExceptionCatcher:
    """Context-manager object.  Create it and feed its `exception` attribute to
    a C API call that wants an `ExceptionInfo` object.  If there seems to be an
    exception set at the end of the `with` block, it will be translated into a
    Python exception.
    """

    cdef _error.ExceptionInfo exception

    def __cinit__(self):
        _error.GetExceptionInfo(&self.exception)

    def __dealloc__(self):
        _error.DestroyExceptionInfo(&self.exception)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        # TODO have more exceptions
        if self.exception.severity != _error.UndefinedException:
            raise GenericMagickException(<bytes>self.exception.reason + <bytes>self.exception.description)

        return False