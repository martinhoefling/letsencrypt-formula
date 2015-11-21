===================
letsencrypt-formula
===================

Creates certificates and manages renewal using the letsencrypt service.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``letsencrypt``
---------------

Installs the letsencrypt cli from git, creates the requested certificates and installs renewal cron job
