include:
  - dhcpd.installed
  - dhcpd.configure

dhcpd:
  require:
    - sls: dhcpd.installed
    - sls: dhcpd.configure
