include:
  - dhcpd.installed

dhcpd:
  require:
    - sls: dhcpd.installed
