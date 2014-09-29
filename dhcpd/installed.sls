{% from "dhcpd/map.jinja" import dhcpd with context %}

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
    'dependencies': dhcpd.dependencies,
    'file': dhcpd.config,
    'require': salt['pillar.get']('dhcpd:config:require', False), 
    'networks': salt['pillar.get']('dhcpd:config:networks', False),
    'keys': salt['pillar.get']('dhcpd:config:keys', False),
    'omapi': {
      'enable': salt['pillar.get']('dhcpd:config:omapi:enable', False),
      'key': salt['pillar.get']('dhcpd:config:omapi:key', False),
    },
} %}

{% if config.manage %}
include:
  - dhcpd.dependencies
{% endif %}

dhcpd.installed:
  require:
    - sls: dhcpd.pkg
{% if service.manage %}
    - sls: dhcpd.service
{% endif %}
{% if config.manage %}
    - sls: dhcpd.config
{% endif %}
{% if config.require %}
  {% for sls in config.require %}
    - sls: {{ sls }}
  {% endfor %}
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
  require:
  {% for dependency in config.dependencies %}
    - pkg: config.dependency.{{ dependency }} 
  {% endfor %}
{% endif %}

{% for dependency in config.dependencies %}
config.dependency.{{ dependency }}:
  pkg.{{ 'latest' if package.upgrade else 'installed' }}:
    - name: {{ dependency }}  
{% endfor %}
