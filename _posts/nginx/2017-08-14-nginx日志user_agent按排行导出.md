---
layout: post
title: nginx日志user_agent按排行导出
categories: nginx
---

zcat ~/path/to/access/logs* | awk -F'"' '{print $6}' | sort | uniq -c | sort -rn | head -n20000 > /home/piwik/top-user-agents.txt