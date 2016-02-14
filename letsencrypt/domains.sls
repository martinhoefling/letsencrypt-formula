# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "letsencrypt/map.jinja" import letsencrypt with context %}


/usr/local/bin/check_letsencrypt_cert.sh:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash

        FIRST_CERT=$1

        for DOMAIN in "$@"
        do
            openssl x509 -in /etc/letsencrypt/live/$1/cert.pem -noout -text | grep DNS:${DOMAIN} > /dev/null || exit 1
        done

{%
  for setname, domainlist in salt['pillar.get'](
    'letsencrypt:domainsets'
  ).iteritems()
%}

create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}:
  cmd.run:
    - unless: /usr/local/bin/check_letsencrypt_cert.sh {{ domainlist|join(' ') }}
    - name: {{
          letsencrypt.cli_install_dir
        }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - cwd: {{ letsencrypt.cli_install_dir }}
    - require:
      - file: letsencrypt-config
      - file: /usr/local/bin/check_letsencrypt_cert.sh

letsencrypt-crontab-{{ setname }}-{{ domainlist[0] }}:
  cron.present:
    - name: {{
          letsencrypt.cli_install_dir
        }}/letsencrypt-auto -d {{ domainlist|join(' -d ') }} certonly
    - month: '*/2'
    - minute: random
    - hour: random
    - daymonth: random
    - identifier: letsencrypt-{{ setname }}-{{ domainlist[0] }}
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}

{% endfor %}
