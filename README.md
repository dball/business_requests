# Business Requests

This is an experiment in modeling business requests as entity objects. By
treating them thusly, we can persist and reason about them directly. This
seems to introduce a handy seam for some cross-cutting concerns:

* authorization: can this user perform this action?
* audit logging: at the business request layer, not the persistence layer
* transactions: allows us to rollback changes at the business request layer,
  outside the boundaries of the persistence layer's transactional support
