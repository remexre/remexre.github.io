+++
+++

# Search Worker

## Overview

Search is generally a hard problem; it's separated here to allow the use of a different technology from the CRUD worker, and to allow it to be scaled separately.
For example, ElasticSearch or Solr could be used, or a custom search worker could be created.

## Tech Recommendation

If you don't need anything particularly special, I'd prefer ElasticSearch.
On the other hand, until you know that you need it, it might also make sense to hold off on creating this.
