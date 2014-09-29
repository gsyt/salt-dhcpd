{% from "dhcpd/map.jinja" import dhcpd with context %}

{% set package = {
    'name': dhcpd.package,
} %}

{% set config = {
    'manage': salt['pillar.get']('dhcpd:config:manage', False), 
    'file': dhcpd.config,
} %}

autofs.purged:
  pkg.purged:
    - name: {{ package.name }}
{% if config.manage %}
  file.absent:
    - name: {{ config.file }}
{%- endfor %}
