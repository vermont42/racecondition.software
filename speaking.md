---
layout: standalone
title: Speaking
---

I am fortunate to have had the opportunity to speak about software development in various public fora, including meet-ups, conferences, and videos.

<div class="table-responsive">
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Title</th>
                <th>Event</th>
                <th>Location</th>
                <th>Links</th>
            </tr>
        </thead>
        <tbody>
        {% for t in site.data.talks %}
        {% assign talk = t[1] %}
        {% assign event = talk.event %}
        {% assign location = talk.location %}
        {% assign links = talk.links %}
            <tr>
                <td>{{ talk.date }}</td>
                <td><i>{{ talk.title }}</i></td>
                <td><a href="{{ event.link }}">{{ event.name }}</a></td>
                <td><a href="{{ location.link }}">{{ location.name }}</a>, {{ location.city }}</td>
                <td>
                    {% if links.slides %}<a href="{{ links.slides }}">slides</a>{% endif %}
                    {% if links.slides and links.video %}&bull;{% endif %}
                    {% if links.video %}<a href="{{ links.video }}">video</a>{% endif %}
                    {% if links.code %}&bull; <a href="{{ links.code }}">code</a>{% endif %}
                </td>
            </tr>
        {% endfor %}
        </tbody>
    </table>
</div>
