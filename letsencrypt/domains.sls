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
        CERT=$(date -d "$(openssl x509 -in /etc/letsencrypt/live/$1/cert.pem -enddate -noout | cut -d'=' -f2)" "+%s")
        CURRENT=$(date "+%s")
        REMAINING=$((($CERT - $CURRENT) / 60 / 60 / 24))
        [ "$REMAINING" -gt "30" ] || exit 1
        echo Domains $@ are in cert and cert is valid for $REMAINING days

/usr/local/bin/renew_letsencrypt_cert.sh:
  file.managed:
    - template: jinja
    - source: salt://letsencrypt/files/renew_letsencrypt_cert.sh.jinja
    - mode: 755
    - require:
      - file: /usr/local/bin/check_letsencrypt_cert.sh

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
    - name: /usr/local/bin/renew_letsencrypt_cert.sh {{ domainlist|join(' ') }}
    - month: '*'
    - minute: random
    - hour: random
    - dayweek: '*'
    - identifier: letsencrypt-{{ setname }}-{{ domainlist[0] }}
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}
      - file: /usr/local/bin/renew_letsencrypt_cert.sh

{% for domain in domainlist %}

create-fullchain-privkey-pem-for-{{ domain }}:
  cmd.run:
    - name: |
        cat /etc/letsencrypt/live/{{ domain }}/fullchain.pem \
            /etc/letsencrypt/live/{{ domain }}/privkey.pem \
            > /etc/letsencrypt/live/{{ domain }}/fullchain-privkey.pem && \
        chmod 600 /etc/letsencrypt/live/{{ domain }}/fullchain-privkey.pem
    - creates: /etc/letsencrypt/live/{{ domain }}/fullchain-privkey.pem
    - require:
      - cmd: create-initial-cert-{{ setname }}-{{ domainlist | join('+') }}

{% endfor %}

{% endfor %}
