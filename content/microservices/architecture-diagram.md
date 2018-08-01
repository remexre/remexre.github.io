+++
+++

```
+---------+                   +-----------+                    +-------------+
| Browser |                   | Googlebot |                    | Android App |
+---------+                   +-----------+                    +-------------+
     ^                              ^                                 ^
     |                              |                                 |
     v                              v                                 v
+----------------------------------------------------------------------------+
| Load Balancer: Handles routing between services. In addition, manages user |
| authentication (not authorization). Also handles applying and sanitizing   |
| HTTP headers, and blocking obvious mischief.                               |
+----------------------------------------------------------------------------+
                 ^                  ^ ^                    ^
                 |                  | |                    |
                 v                  | |                    v
+---------------------------------+ | |  +-----------------------------------+
| CRUD Worker: Responds to most   | | |  | Search Worker: Performs all the   |
| API requests,enforces security  | | |  | computation required to perform a |
| policy.                         | | |  | search.                           |
+---------------------------------+ | |  +-----------------------------------+
                 ^                  | |                    ^
                 |                  | |                    |
                 |              +---|-|--------------------+
                 |              |   | |
                 v              v   | |
+---------------------------------+ | |  +-----------------------------------+
| Database: This should be all    | | |  | Template Render Worker: Performs  |
| permanent data. In essence,     | | +->| rendering of templates for the    |
| this is the only component that | |    | website. This is mainly needed    |
| needs backups.                  | |    | for SEO and people who have       |
+---------------------------------+ |    | JavaScript disabled.              |
                 ^       ^          |    +-----------------------------------+
                 |       |          |    +-----------------------------------+
                 |       |          +--->| External API Workers: Perform all |
                 |       +-------------->| the external API calls. Also      |
                 v                       | manage caching external calls.    |
+---------------------------------+      +-----------------------------------+
| Machine Learning Workers: Any   |                        ^
| fancy data science, machine     |                        |
| learning, neural nets, etc.     |                        |
| should be performed as close to |                        |
| offline as possible. Doing it   |                        |
| directly on the database is the |                        v
| closest we're probably going to |              +-------------------+
| get.                            |              | External Services |
+---------------------------------+              +-------------------+
```
