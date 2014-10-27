{% from "dhcpd/map.jinja" import dhcpd with context %}

{% set require = salt['pillar.get']('dhcpd:require', []) %}

{% set package = {
  'name': dhcpd.package,
  'upgrade': salt['pillar.get']('dhcpd:package:upgrade', False),
} %}

{% set service = {
  'name': dhcpd.service,
  'manage': salt['pillar.get']('dhcpd:service:manage', False), 
  'enable': salt['pillar.get']('dhcpd:service:enable', True), 
} %}

{% set config = {
  'manage': salt['pillar.get']('dhcpd:config:manage', False), 
  'file': dhcpd.config,
  'contents': salt['pillar.get']('dhcpd:config:contents', ''),
  'source': salt['pillar.get']('dhcpd:config:source', 'salt://dhcpd/conf/dhcpd.conf'),
  'networks': salt['pillar.get']('dhcpd:config:networks', []),
  'zones': salt['pillar.get']('dhcpd:config:zones', []),
  'keys': salt['pillar.get']('dhcpd:config:omapi:keys', []),
} %}

dhcpd.installed:
  require:
    - sls: dhcpd.pkg
{% if require %}
  {% for sls in require %}
    - sls: {{ sls }}
  {% endfor %}
{% endif %}
{% if service.manage %}
    - sls: dhcpd.service
{% endif %}
{% if config.manage %}
    - sls: dhcpd.config
{% endif %}

dhcpd.pkg:
  pkg.{{ 'latest' if package.upgrade else 'installed' }}:
    - name: {{ package.name }}

{% if service.manage %}
dhcpd.service:
  service.{{ 'running' if service.enable else 'dead' }}:
    - name: {{ service.name }}
  require:
    - pkg: dhcpd.installed
  {% if config.manage %}
    - sls: dhcpd.config
  watch:
    - file: dhcpd.config
    - pkg: dhcpd.pkg
  {% else %}
  watch:
    - pkg: dhcpd.pkg
  {% endif %}
{% endif %}

{% if config.manage %}
dhcpd.config:
  file.managed:
    - name: {{ config.file }}
    - template: jinja
  {% if config.contents %}
    - contents_pillar: dhcpd:config:contents
  {% else %}
    - source: {{ config.source }}
  {% endif %}
{% endif %}
