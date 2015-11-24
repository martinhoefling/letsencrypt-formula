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

Installs and configures the letsencrypt cli from git, creates the requested certificates and installs renewal cron job.
This is a shortcut for letsencrypt.install letsencrypt.config and letsencrypt.domains .

``install``
-----------

Only installs the letsencrypt client. Currently the letsencrypt-auto method is used. This will create a virtualenv in the /root/.config/ directory.
The installation method will be replaced by using packages, as default as soon as they ara stable and available for all major platforms.
``config``
----------

Manages /etc/letsencrypt/cli.ini config file.

``domains``
-----------
Creates a certificate with the domains in each domain set (letsencrypt:domainsets in pillar). Letsencrypt uses a relatively short validity of 90 days.
Therefore, a cron job for automatic renewal every 60 days is installed for each domain set as well.
