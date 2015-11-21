# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}

{% for setname, domainlist in pillar['letsencrypt']['domainsets'].iteritems() %}
create-initial-cert-{{ setname }}-{{ domainlist[0] }}:
  cmd.run:
    - unless: ls /etc/letsencrypt/live/{{ domainlist[0] }}
    - name: cd {{ letsencrypt.cli_install_dir }}; ./letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly

letsencrypt-crontab--{{ setname }}-{{ domainlist[0] }}:
  cron.present:
    - name: cd {{ letsencrypt.cli_install_dir }}; ./letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - month: '*/2'
    - minute: random
    - hour: random
    - daymonth: random
{% endfor %}
