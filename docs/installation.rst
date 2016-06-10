.. highlight:: shell

============
Installation
============


Stable release
--------------

To run pymspack, you need the `libmspack` library. In Debian/Ubuntu, run:

.. code-block:: console

    $ sudo apt install libmspack0

To compile the native extension, you need the `libmspack` header files. In Debian/Ubuntu, run:

.. code-block:: console

    $ sudo apt install libmspack-dev


To install Python pymspack, run this command in your terminal:

.. code-block:: console

    $ pip install pymspack

This is the preferred method to install Python mspack, as it will always install the most recent stable release.

If you don't have `pip`_ installed, this `Python installation guide`_ can guide
you through the process.

.. _pip: https://pip.pypa.io
.. _Python installation guide: http://docs.python-guide.org/en/latest/starting/installation/


From sources
------------

You'll need the `libmspack` library.In Debian/Ubuntu, run:

.. code-block:: console

    $ sudo apt install libmspack0 libmspack-dev


The sources for Python pymspack can be downloaded from the `Github repo`_.

You can either clone the public repository:

.. code-block:: console

    $ git clone git://github.com/gcrahay/pymspack

Or download the `tarball`_:

.. code-block:: console

    $ curl  -OL https://github.com/gcrahay/pymspack/tarball/master

Once you have a copy of the source, you can install it with:

.. code-block:: console

    $ python setup.py install


.. _Github repo: https://github.com/gcrahay/pymspack
.. _tarball: https://github.com/gcrahay/pymspack/tarball/master
