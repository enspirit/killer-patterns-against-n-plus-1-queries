# Killing N+1 queries in a safe way

N+1 are a software engineering plague. They should always be removed the right
way, via massive refactoring or complete rewrite.

In certain situations, though, such refactoring is too costly and one wants
quick & not-too-dirty patterns to kill some loop over the database while
minimizing code changes.

This repository introduces N+1 refactoring patterns that are correct and
relatively easy to implement.

## Memoized callee

A pattern where a `caller (1 query) -> callee (N queries)` is transformed
to `caller (1 query) -> callee (1 query + caching)` with only a few changes
and the business logic mostly untouched.

[See the code](./memoized_callee/)
