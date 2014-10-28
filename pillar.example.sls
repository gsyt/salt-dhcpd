dhcpd:
  package:
    upgrade: False
  require:
    - autofs
  service:
    manage: False
    enable: True
  config:
    manage: False
    options:
      - ddns-update-style interim
    networks:
      trust:
        address: 192.168.0.0
        netmask: 255.255.255.0
        options:
          - option router 192.168.0.1
          - options domain-name-servers 192.168.0.1
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
    hosts:
      host01:
        - hardware ethernet aa:bb:cc:dd:ee:ff
        - fixed-address 192.168.0.2
    omapi:
      key: key03
  lookup:
    package: dhcp
    service: dhcpd
    config: /etc/dhcp/dhcpd.conf
