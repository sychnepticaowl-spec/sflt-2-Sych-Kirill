# 🛡️ Домашнее задание 13-01: Уязвимости и атаки на информационные системы

**Выполнил:** Сыч Кирилл  
**Группа:** SFLT-58  
**Дата:** 25 октября 2026

[![Nmap](https://img.shields.io/badge/Nmap-7.94SVN-blue)](https://nmap.org/)
[![Metasploitable](https://img.shields.io/badge/Metasploitable-2-red)](https://sourceforge.net/projects/metasploitable/)

---

## 📋 Содержание

- [Задание 1: Сканирование Metasploitable и поиск уязвимостей](#-задание-1-сканирование-metasploitable-и-поиск-уязвимостей)
- [Задание 2: SYN, FIN, Xmas и UDP-сканирование](#-задание-2-syn-fin-xmas-и-udp-сканирование)
- [Воспроизведение](#-воспроизведение)

---

## 🎯 Задание 1: Сканирование Metasploitable и поиск уязвимостей

### ✅ Выполненные действия

1. Запущена **Metasploitable 2** в Docker: `./lab/start-metasploitable.sh` (образ `q8dusty/metasploitable2`, `network_mode: host`).
2. Цель сканирования с хоста: **127.0.0.1** (`localhost`).
3. Выполнено: `nmap -sV --reason 127.0.0.1` (~152 с).
4. По версиям служб — поиск эксплойтов на [Exploit Database](https://www.exploit-db.com/).

**Артефакты:** [scans/task1-sV.txt](scans/task1-sV.txt) · [scripts/task1-nmap.sh](scripts/task1-nmap.sh)

### 🌐 Какие сетевые службы разрешены?

По результатам `nmap -sV` (22 открытых TCP-порта; **978** портов **closed**, `conn-refused`):

| Порт | Служба | Версия |
|------|--------|--------|
| 21/tcp | FTP | vsftpd **2.3.4** |
| 22/tcp | SSH | OpenSSH **4.7p1** |
| 23/tcp | Telnet | Linux telnetd |
| 25/tcp | SMTP | Postfix smtpd |
| 80/tcp | HTTP | Apache **2.2.8** |
| 111/tcp | rpcbind | RPC #100000 |
| 139, 445/tcp | SMB | Samba smbd **3.X–4.X** |
| 512/tcp | rexec | exec? |
| 513/tcp | rlogin | login |
| 514/tcp | rsh | tcpwrapped |
| 631/tcp | IPP | CUPS 2.4 |
| 1099/tcp | Java RMI | GNU Classpath grmiregistry |
| 1524/tcp | shell | **Metasploitable bindshell** (root) |
| 2121/tcp | FTP | ProFTPD **1.3.1** |
| 3306/tcp | MySQL | **5.0.51a** |
| 5432/tcp | PostgreSQL | **8.3.x** |
| 5900/tcp | VNC | protocol 3.3 |
| 6000/tcp | X11 | access denied |
| 6667/tcp | IRC | **UnrealIRCd** |
| 8009/tcp | AJP13 | Apache Jserv |
| 8180/tcp | HTTP | Apache Tomcat |

**UDP** (см. задание 2, [scans/task2-udp.txt](scans/task2-udp.txt)): открыты **137/netbios-ns**, **161/snmp**; **69/tftp** — `open|filtered`.

**ОС:** Linux (CPE `linux_kernel`), hostname `metasploitable.localdomain`.

### 🔓 Обнаруженные уязвимости (≥ 3)

| № | Служба (версия из nmap) | Описание | Exploit-DB |
|---|-------------------------|----------|------------|
| 1 | vsftpd **2.3.4** | Backdoor: логин `user:)`, на **6200/tcp** — shell | [17491](https://www.exploit-db.com/exploits/17491) |
| 2 | Samba **3.0.20** (семейство 3.x) | RCE `username map script` | [16320](https://www.exploit-db.com/exploits/16320) |
| 3 | UnrealIRCd **3.2.8.1** (баннер IRC на :6667) | Backdoor в исходниках дистрибутива | [13853](https://www.exploit-db.com/exploits/13853) |

Дополнительно по тем же результатам nmap:

| Служба | Exploit-DB |
|--------|------------|
| ProFTPD 1.3.1 (`mod_copy`, CVE-2015-3306) | [36742](https://www.exploit-db.com/exploits/36742) |
| MySQL 5.0.51a (слабые пароли, UDF) | [1518](https://www.exploit-db.com/exploits/1518) |
| Java RMI / grmiregistry :1099 | [42753](https://www.exploit-db.com/exploits/42753) |

**Вывод:** цель — намеренно уязвимый стенд; цепочка «nmap -sV → версия → Exploit-DB» даёт несколько подтверждённых точек входа для учебной эксплуатации **только в изолированной сети**.

### 📸 Скриншот

![Nmap -sV](https://github.com/sychnepticaowl-spec/13-01-Sych-Kirill/blob/main/screenshots/task1-nmap-sV.png)
*Рисунок 1 — `nmap -sV --reason 127.0.0.1`*

---

## 🎯 Задание 2: SYN, FIN, Xmas и UDP-сканирование

### ✅ Выполненные действия

1. Та же цель **127.0.0.1** (Metasploitable 2 в Docker).
2. Захват трафика **tcpdump** на интерфейсе **lo** → [pcap/](pcap/) (`task2-syn.pcap`, `task2-fin.pcap`, `task2-xmas.pcap`, `task2-udp.pcap`). Скрипт: [scripts/capture-scans-pcap.sh](scripts/capture-scans-pcap.sh).
3. Сканирования nmap (raw, Docker `instrumentisto/nmap`):

```bash
nmap -sS -p 21,22,23,25,80,139,445,3306,5432,6667 127.0.0.1
nmap -sF -p 21,22,23,25,80,139,445,3306,5432,6667 127.0.0.1
nmap -sX -p 21,22,23,25,80,139,445,3306,5432,6667 127.0.0.1
nmap -sU --top-ports 20 127.0.0.1
```

Логи: [scans/task2-syn.txt](scans/task2-syn.txt), [task2-fin.txt](scans/task2-fin.txt), [task2-xmas.txt](scans/task2-xmas.txt), [task2-udp.txt](scans/task2-udp.txt).

### 📊 Результаты nmap (факт)

**SYN** — все 10 портов **`open`** (21, 22, 23, 25, 80, 139, 445, 3306, 5432, 6667).

**FIN и Xmas** — те же порты **`open|filtered`** (на Linux открытые порты часто не отвечают на FIN/Xmas).

**UDP (top 20)** — **`open`:** 137, 161; **`open|filtered`:** 69; **`closed`:** 53, 67, 68, 123, … (ICMP port unreachable).

### 📡 Чем отличаются режимы по трафику?

| Режим | Что шлёт nmap | Открытый TCP | Закрытый TCP | UDP |
|-------|---------------|--------------|--------------|-----|
| **SYN `-sS`** | SYN, при SYN-ACK — **RST** (half-open) | SYN-ACK | RST | — |
| **FIN `-sF`** | TCP **FIN** | часто **тишина** | RST | — |
| **Xmas `-sX`** | **FIN+PSH+URG** | как FIN | RST | — |
| **UDP `-sU`** | UDP-датagram | — | — | ответ UDP или **ICMP type 3 code 3** |

На **127.0.0.1** (loopback) SYN виден в Wireshark как **SYN → SYN-ACK → RST** ([scans/wireshark-syn.txt](scans/wireshark-syn.txt), [pcap/task2-syn.pcap](pcap/task2-syn.pcap)).

### 🖥️ Как отвечает сервер?

- **SYN:** на :22 — кадры `[SYN]`, затем `[SYN, ACK]`, затем `[RST]` от сканера (см. рис. 2).
- **FIN / Xmas:** исходящие FIN (или «ёлка») на 21, 22, 80… **без ответа** на открытых портах → nmap: `open|filtered` ([scans/task2-fin.txt](scans/task2-fin.txt)).
- **UDP:** на закрытые порты — **ICMP Destination unreachable (Port unreachable)**; на **137** и **161** — ответы служб ([scans/task2-udp.txt](scans/task2-udp.txt), [pcap/task2-udp.pcap](pcap/task2-udp.pcap)).

### 📸 Скриншоты

![SYN Wireshark](https://github.com/sychnepticaowl-spec/13-01-Sych-Kirill/blob/main/screenshots/task2-wireshark-syn.png)
*Рисунок 2 — SYN-скан, порт 22: SYN / SYN-ACK / RST*

![FIN Wireshark](https://github.com/sychnepticaowl-spec/13-01-Sych-Kirill/blob/main/screenshots/task2-wireshark-fin.png)
*Рисунок 3 — FIN-скан: только FIN от клиента, ответа нет*

![UDP Wireshark](https://github.com/sychnepticaowl-spec/13-01-Sych-Kirill/blob/main/screenshots/task2-wireshark-udp.png)
*Рисунок 4 — UDP-скан: ICMP port unreachable*

![SYN nmap](https://github.com/sychnepticaowl-spec/13-01-Sych-Kirill/blob/main/screenshots/task2-nmap-syn.png)
*Рисунок 5 — вывод `nmap -sS`*

---

## 🔄 Воспроизведение

```bash
./lab/start-metasploitable.sh          # Metasploitable 2 → 127.0.0.1
./scripts/task1-nmap.sh 127.0.0.1      # задание 1
./scripts/capture-scans-pcap.sh        # pcap на lo (задание 2)
./scripts/task2-scans.sh 127.0.0.1     # SYN/FIN/Xmas/UDP
python3 scripts/render-screenshots.py  # PNG для README
./lab/stop-metasploitable.sh
```

Raw-сканы без root: [scripts/nmap-raw.sh](scripts/nmap-raw.sh) (Docker).  
Открыть pcap: `wireshark pcap/task2-syn.pcap` (интерфейс **lo**).
