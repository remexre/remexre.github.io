+++
+++

# Load Balancer

## Overview

In a non-monolithic architecture, there needs to be some way to route API requests from clients to services, and between services.
Enter the load balancer.

The load balancer's role is routing requests to different services.
As your backend scales up, it will, as the name suggests, balance load by delegating requests to different clusters of services.
It should also be in charge of applying TLS, and can also sanitize headers and apply basic firewall rules.

## Tech Recommendation

Usually this is just a reasonably long nginx config file which specifies how to route and balance different requests.
You could write your own as well, probably in C or Rust for performance reasons.
