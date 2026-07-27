# ⚖️ Домашнее задание 2: Кластеризация и балансировка нагрузки

**Выполнил:** Сыч Кирилл  
**Группа:** SFLT-58  
**Дата:** 28 июля 2026

[![HAProxy](https://img.shields.io/badge/HAProxy-2.8-orange)](https://www.haproxy.org/)

---

## 📋 Содержание

- [Задание 1: Round-robin на 4 уровне](#-задание-1-round-robin-на-4-уровне-tcp)
- [Задание 2: Weighted Round Robin на 7 уровне](#-задание-2-weighted-round-robin-на-7-уровне-http)

---

## 🎯 Задание 1: Round-robin на 4 уровне (TCP)

### ✅ Выполненные действия

1. Запущены 2 Python HTTP-сервера на портах **8888** и **9999**
2. Установлен и настроен HAProxy
3. Настроена балансировка **Round-robin на L4** (секция `listen web_tcp`, `mode tcp`)
4. HAProxy слушает порт **1325** и распределяет TCP-соединения между backend-серверами

### 📋 Конфигурация backend-серверов

| № | Сервер | Порт | Содержимое index.html |
|---|--------|------|------------------------|
| 1 | s1 | 8888 | Server 1 Port 8888 |
| 2 | s2 | 9999 | Server 2 Port 9999 |

### ⚙️ Конфигурация HAProxy (фрагмент)

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

### 🧪 Проверка Round-robin

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

### 📸 Скриншот

![Round-robin L4](https://github.com/sychnepticaowl-spec/sflt-2-Sych-Kirill/blob/main/screenshots/task1-roundrobin.png)
*Рисунок 1 — Round-robin на 4 уровне: чередование ответов серверов 8888 и 9999 через HAProxy :1325*

---

## 🎯 Задание 2: Weighted Round Robin на 7 уровне (HTTP)

### ✅ Выполненные действия

1. Запущены 3 Python HTTP-сервера на портах **8081**, **8082**, **8083**
2. Настроена балансировка **Weighted Round Robin** с весами **2, 3, 4**
3. HAProxy балансирует только HTTP-трафик с заголовком `Host: example.local`
4. Запросы без этого домена получают **403 Forbidden**

### 📋 Конфигурация backend-серверов

| № | Сервер | Порт | Вес | Содержимое index.html |
|---|--------|------|-----|------------------------|
| 1 | s1 | 8081 | 2 | Server 1 Port 8081 (weight 2) |
| 2 | s2 | 8082 | 3 | Server 2 Port 8082 (weight 3) |
| 3 | s3 | 8083 | 4 | Server 3 Port 8083 (weight 4) |

### ⚙️ Конфигурация HAProxy (фрагмент)

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

### 🧪 Проверка с доменом example.local

```bash
for i in $(seq 1 9); do curl -s -H "Host: example.local" http://127.0.0.1:8088/index.html; done
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

### 🧪 Проверка без домена example.local

```bash
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:8088/index.html
# HTTP status: 403
```

### 📸 Скриншоты

**⚖️ Weighted Round Robin с `example.local`:**

![Weighted RR L7](https://github.com/sychnepticaowl-spec/sflt-2-Sych-Kirill/blob/main/screenshots/task2-weighted.png)
*Рисунок 2 — Балансировка по весам 2:3:4 при обращении с доменом `example.local`*

**🚫 Запрос без домена:**

![403 Forbidden](https://github.com/sychnepticaowl-spec/sflt-2-Sych-Kirill/blob/main/screenshots/task2-weighted-403.png)
*Рисунок 3 — Ответ 403 Forbidden при обращении без заголовка `Host: example.local`*

**📊 Статистика HAProxy:**

![Статистика HAProxy](https://github.com/sychnepticaowl-spec/sflt-2-Sych-Kirill/blob/main/screenshots/stats-HAProxy.png)
*Рисунок 4 — Страница статистики HAProxy (http://127.0.0.1:19888/stats)*
