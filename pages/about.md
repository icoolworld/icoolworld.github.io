---
layout: page
title: About Me
description: 因码而生,我是码农
keywords: 码农,it
comments: true
menu: 关于
permalink: /about/
---

我是IT码农，三十而立

仰慕「优雅编码的艺术」。

坚信熟能生巧，努力改变人生。

## Contact

{% for website in site.data.social %}
* {{ website.sitename }}：[@{{ website.name }}]({{ website.url }})
{% endfor %}

## Skill Keywords

{% for category in site.data.skills %}
### {{ category.name }}
<div class="btn-inline">
{% for keyword in category.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
