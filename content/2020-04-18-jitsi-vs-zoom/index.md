+++
title = "Initial Impressions: Jitsi vs Zoom"

[taxonomies]
tags = []

[extra]
comment_issue = 8
+++

I've been using Zoom via the Linux client at work. Last night, I tried out Jitsi with some friends; my review is:

Pros:

-	Yay, Self-Hosting! A friend installed it on a DigitalOcean droplet in ~10 minutes. (Note that he already had a domain to add DNS records to.)
-	Nicer UI than zoom (subjectively)
-	Works in browser with no install on PC
-	Chat and hand-raising are easier to see in the UI
-	Rooms have names instead of numbers
-	There's a pretty cool [blur mode](blur-mode.png) for privacy, but it reduces the framerate of your video drastically, even on a powerful machine

Cons:

-	Seems to require more bandwidth? didn't measure, but a friend on a slower inet connection who doesn't usually have issues with zoom was breaking up on video and audio
	-	Mitigation: there's a separate low-bandwidth mode he turned on that made it easier to understand him
-	On Android, requires the app; I haven't tried zoom on mobile though, so that might be same
-	Chat on mobile seems buggy (hard to close the UI, some things were overlapping on my device)
-	It looks like the only permissions are "is this client allowed by the server" rather than "is this user allowed to join this room"
	-	Somewhat mitigated by it autogenerating high-entropy names for rooms, e.g. GrossBasketsSuspendSeriously
-	By default, there's a watermark for guest users; this is allegedly easy to disable in the config, though.
-	Screensharing is relatively laggy; it's fine for slides or coding, but it made streaming games to each other difficult
-	No push-to-talk. Zoom doesn't support this on Linux either, but still a con.
-	No virtual backgrounds. A lot of people are asking for it though, and I conjecture that the code for blur mode could probably be extended without too much pain to provide this; hopefully it'll be coming soon.

Mixed Pro/Con:

-	There's a concept of "the current speaker," and everyone else has their mic quieter; this is nice when some people have slightly noisy backgrounds, but it makes it hard to interrupt someone
-	Instead of meetings you invite people to that start at a given time, there's rooms anyone with the link can join at any time; though as far as I can tell, you can configure either one to act like the other

Overall, Jitsi seems better for the case of "some friends chatting," and probably for smaller meetings.
