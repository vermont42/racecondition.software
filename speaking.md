---
layout: standalone
title: Speaking
---

I am proud to have spoken in public about software development on several occasions. The preparation is intense, but the reward is great.

### Upcoming and Past Talks

<div class="table-responsive">
    <table class="table table-striped table-bordered">
        <thead>
            <tr>
                <th><i class="fa fa-calendar" aria-hidden="true"></i>&nbsp; Date</th>
                <th><i class="fa fa-quote-left" aria-hidden="true"></i>&nbsp; Title</th>
                <th><i class="fa fa-video-camera" aria-hidden="true"></i>&nbsp; Event</th>
                <th><i class="fa fa-map-marker" aria-hidden="true"></i>&nbsp; Location</th>
                <th><i class="fa fa-file-text" aria-hidden="true"></i>&nbsp; Links</th>
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
