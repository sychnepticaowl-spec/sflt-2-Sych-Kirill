# PCAP (задание 2)

Файлы сняты на **lo** при сканировании **127.0.0.1** (Metasploitable 2, Docker host network):

| Файл | Скан |
|------|------|
| [task2-syn.pcap](task2-syn.pcap) | `nmap -sS` |
| [task2-fin.pcap](task2-fin.pcap) | `nmap -sF` |
| [task2-xmas.pcap](task2-xmas.pcap) | `nmap -sX` |
| [task2-udp.pcap](task2-udp.pcap) | `nmap -sU --top-ports 20` |

Повтор: `./scripts/capture-scans-pcap.sh`

В Wireshark: фильтр `tcp.port == 22` (SYN) или `icmp` (UDP).
