# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

letsencrypt-config:
  file.managed:
    - name: {{ letsencrypt.cli_install_dir }}/cli.ini
    - makedirs: true
    - contents_pillar: letsencrypt:config
