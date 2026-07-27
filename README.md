# Домашнее задание к занятию 2 «Кластеризация и балансировка нагрузки» — Сыч Кирилл Павлович

---

## Задание 1 — Round-robin на 4 уровне (TCP)

### Что сделано

1. Запущены 2 Python HTTP-сервера на портах **8888** и **9999**
2. Установлен и настроен HAProxy
3. Настроена балансировка **Round-robin на L4** (секция `listen web_tcp`, `mode tcp`)
4. HAProxy слушает порт **1325** и распределяет TCP-соединения между backend-серверами

### Запуск

```bash
./install-haproxy.sh   # при первом запуске
./start.sh start
```

### Конфигурация HAProxy (фрагмент задания 1)

```haproxy
listen web_tcp
    bind 127.0.0.1:1325
    mode tcp
    balance roundrobin
    option tcplog
    server s1 127.0.0.1:8888 check inter 3s
    server s2 127.0.0.1:9999 check inter 3s
```

Полный конфиг: [config/haproxy.cfg](config/haproxy.cfg)

### Проверка Round-robin

```bash
for i in 1 2 3 4 5 6; do curl -s http://127.0.0.1:1325/index.html; done
```

Результат — чередование ответов между серверами:

```
Request 1: Server 1 Port 8888
Request 2: Server 2 Port 9999
Request 3: Server 1 Port 8888
Request 4: Server 2 Port 9999
Request 5: Server 1 Port 8888
Request 6: Server 2 Port 9999
```

![Round-robin L4](screenshots/task1-roundrobin.txt)

---

## Задание 2 — Weighted Round Robin на 7 уровне (HTTP)

### Что сделано

1. Запущены 3 Python HTTP-сервера на портах **8081**, **8082**, **8083**
2. Настроена балансировка **Weighted Round Robin** с весами **2, 3, 4**
3. HAProxy балансирует только HTTP-трафик с заголовком `Host: example.local`
4. Запросы без этого домена получают **403 Forbidden**

### Конфигурация HAProxy (фрагмент задания 2)

```haproxy
frontend example_local
    bind 127.0.0.1:8088
    mode http
    acl ACL_example_local hdr(host) -i example.local
    use_backend web_servers if ACL_example_local
    default_backend deny_other

backend web_servers
    mode http
    balance roundrobin
    option httpchk GET /index.html
    server s1 127.0.0.1:8081 weight 2 check inter 3s
    server s2 127.0.0.1:8082 weight 3 check inter 3s
    server s3 127.0.0.1:8083 weight 4 check inter 3s

backend deny_other
    mode http
    http-request deny deny_status 403
```

### Проверка с доменом example.local

```bash
curl -H "Host: example.local" http://127.0.0.1:8088/index.html
```

Распределение по весам 2:3:4 (9 запросов → 2 + 3 + 4):

```
Request 1: Server 3 Port 8083 (weight 4)
Request 2: Server 2 Port 8082 (weight 3)
Request 3: Server 3 Port 8083 (weight 4)
Request 4: Server 1 Port 8081 (weight 2)
Request 5: Server 2 Port 8082 (weight 3)
Request 6: Server 3 Port 8083 (weight 4)
Request 7: Server 3 Port 8083 (weight 4)
Request 8: Server 2 Port 8082 (weight 3)
Request 9: Server 1 Port 8081 (weight 2)
```

### Проверка без домена example.local

```bash
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:8088/index.html
# HTTP status: 403
```

![Weighted RR L7](screenshots/task2-weighted.txt)

### Статистика HAProxy

Страница stats: http://127.0.0.1:19888/stats  
Сохранённый HTML: [screenshots/haproxy-stats.html](screenshots/haproxy-stats.html)

---

## Структура проекта

```
sflt-2-hw/
├── config/haproxy.cfg      # конфигурация HAProxy
├── servers/                # директории Python-серверов
├── screenshots/            # результаты проверок
├── start.sh                # запуск/остановка всех сервисов
└── install-haproxy.sh      # установка HAProxy без sudo
```

## Примечание

HAProxy установлен локально в `bin/` (без `sudo apt install`), так как на VM нет пароля для sudo.  
Для production-окружения достаточно: `sudo apt install haproxy` и скопировать `config/haproxy.cfg` в `/etc/haproxy/haproxy.cfg`.
