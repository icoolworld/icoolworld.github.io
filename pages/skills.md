---
layout: page
title: Skills
description: 学无止境,活到老学到老
keywords: 专业技能
comments: true
menu: 技能
permalink: /skills/
---

> 学无止境,活到老学到老

{% for skill in site.data.skills %}
## {{ skill.name }}
    {% for keyword in skill.keywords %}
    {{keyword}}
    {% endfor %}
{% endfor %}
