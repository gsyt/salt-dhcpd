dhcpd:
  package:
    upgrade: False
  service:
    manage: False
    enable: True
  config:
    manage: False
    require:
      - autofs
    networks:
      trust:
        address: 192.168.0.0
        netmask: 255.255.255.0
        range:
          - 192.168.0.2 192.168.0.254
        options:
          - router 192.168.0.1
          - domain name servers 192.168.0.1
    zones:
      test1.example.org:
        primary: ns01.example.org
        key: key01
      test2.example.org:
        primary: ns01.example.org
        key: key02
    keys:
      key01:
        algorithm: HMAC-MD5
        secret: xxxxxxx
      key02:
        algorithm: HMAC-MD5
        secret: yyyyyyy
      key03:
        algorithm: HMAC-MD5
        secret: zzzzzzz
    omapi:
      enable: False
      key: key03
  lookup:
    dependencies:
      - python-augeas
      - augeas
    package: dhcp
    service: dhcpd
    config: /etc/dhcp/dhcpd.conf
