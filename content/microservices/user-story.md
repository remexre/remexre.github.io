+++
+++

## Before/Problem

ACM wants to pick a location to eat dinner.
We've got a group of 10 people, with 2 vegetarians, 1 vegan, and 1 non-pork-consuming individual.
We don't want to go to a restaurant with an average entree cost under $12 (although it might make sense to hide the amount each user "votes" for and choose a weighted average?)
Additionally, we don't want to go to somewhere people have been recently, although people also don't want to write down a list of locations they've been recently every day.
Lastly, we don't want to walk more than 10 minutes.

However, this results in 20 minutes of arguing.

## After/Solution

Everyone opens the app on their phone or laptop.
Only 6 people have the app, so some people need to install it.
Installing the app on Android doesn't require much setup, since the user signs into the app with the same Google account they used to download it, so it's a single click at the first time the app is opened.
TODO: Is the same true for iOS?
On the web, it's slightly slower, since users have to sign into their Google/Facebook/Twitter/Yahoo/Yandex/... account.
The first-time users also need to enter their name (for identification in the group) and dietary requirements.
However, getting started with the webapp and joining a group still takes a reasonably competent user less than 200 seconds.

Using a group code / Bluetooth / NFC / WiFi Direct / Ultrasonic, people all join a group.
The group leader chooses a range to find restaurants in (e.g. 10 minutes walking, 15 minutes driving, 5 miles, 8 km).
Since people already have their dietary preferences in the app, restaurants that don't provide reasonable accomodation for these preferences aren't shown.
People are each shown restaurants, which they can choose Thumbs Up / Ambivalent / Thumbs Down on a restaurant.
The restaurant with the highest aggregate vote that meets the given criteria is chosen.

The voting process takes less than 5 minutes, and the entire process including app installation takes less than 10 minutes.
