# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

{% for setname, domainlist in pillar['letsencrypt']['domainsets'].iteritems() %}
create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}:
  cmd.run:
    - unless: ls /etc/letsencrypt/{{ domainlist | join('.check /etc/letsencrypt/') }}.check
    - name: {{ letsencrypt.cli_install_dir }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - cwd: {{ letsencrypt.cli_install_dir }}
    - require:
      - file: letsencrypt-config

touch /etc/letsencrypt/{{ domainlist | join('.check /etc/letsencrypt/') }}.check:
  cmd.run:
    - unless: test -f /etc/letsencrypt/{{ domainlist | join('.check && test -f /etc/letsencrypt/') }}.check
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}

letsencrypt-crontab-{{ setname }}-{{ domainlist[0] }}:
  cron.present:
    - name: {{ letsencrypt.cli_install_dir }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - month: '*/2'
    - minute: random
    - hour: random
    - daymonth: random
    - identifier: letsencrypt-{{ setname }}-{{ domainlist[0] }}
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}

{% endfor %}
