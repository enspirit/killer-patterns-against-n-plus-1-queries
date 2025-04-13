# Refactoring patterns to kill N+1 queries in a safe way

`N+1 queries` are a software engineering plague.

If you're not convinced yet, consider the following numbers
(ran on our `prefetch-and-cache` example on a Apple M1, see last section) :

* Let's say a roundtrip with your database server takes `5ms`
* `N+1 queries` takes about `7 seconds` when `N=1000`
* Once the `N+1` is removed the same program takes `360ms`

That's convervative: lots of software out there have `(1+M)*(1+N)` queries,
because they make a massive use of loops with lots of small queries sent to
their database server. That is, their complexity is often in `O(N^2)` or `O(N)`
where the could most of the time do the same job in `O(1)`.

`N+1 queries` should always be removed the right way, via massive refactoring or
a complete software rewrite.

In certain situations, though, such a refactoring is too costly and one wants
quick & not-too-dirty patterns to kill some loops over the database while
minimizing changes in business logic.

This repository introduces `N+1 refactoring patterns` that are correct and
relatively easy to implement. Patterns are listed in the following sections.

All examples are built under the assumption that you have `N+1 queries` against
a `SQL database`. That said, they are more generally applicable to situations
where you have `N+1 calls over some I/O` while the service behind this `I/O`
supports plural forms for queries (e.g. any decent database server, Restful API,
etc.)

Find instructions at the bottom of this README to execute the examples.

## Prefetch & Cache

A pattern where a `caller (1 query) -> callee (N queries)` is transformed
to `caller (1 query) -> callee (1 query + caching)` with only a few changes
and the business logic mostly untouched.

The pattern follows our intuition, but you might be surprised to discover
that the caching is done on the callee side.

[See the code](./prefetch-and-cache/)

## How to install & run the examples ?

You'll need a recent ruby version and sqlite3. Then:

```sh
$ make install
$ make run
```

You should end up with a result that looks like this :

```sh
time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/before.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m6.891s
user	0m0.514s
sys	0m0.149s
time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/after.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m0.358s
user	0m0.250s
sys	0m0.062s
```

The results are crystal clear.
