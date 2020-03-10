# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

letsencrypt-certbot-pkg:
  pkg.installed:
    - name: certbot
