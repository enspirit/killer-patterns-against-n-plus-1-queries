# Killing N+1 queries in a safe way

N+1 are a software engineering plague. They should always be removed the right
way, via massive refactoring or complete rewrite.

In certain situations, though, such refactoring is too costly and one wants
quick & not-too-dirty patterns to kill some loop over the database while
minimizing code changes.

This document shows a pattern where a `caller -> callee` involving N+1 queries
can be refactored by mostly keeping the `caller` untouched, and refactoring the
`callee` to use the database in smarter way, and caching results.

IMPORTANT: the pattern is only valid if `callee` is a pure function without
side effects, i.e. its results only depend on the input arguments (if global
software state is considered stable enough during the entire `caller` execution)

## Before (in pseudo code)

```ruby
# we don't want to touch the loop code
function caller
  N = SQL("parent")
  for i in N
    callee(i)
end

# we may refactor this one to use a smarter SQL query
function callee(i)
  ri = SQL("child", i)
  return some_result(ri)
end
```

## After (in pseudo code)

```ruby
# we only touch two lines of code
function caller
  N = SQL("parent")
  cache = callee(N)                          ## prefetch & cache
  for i in N
    callee(i, cache)                         ## one argument added
end

# we may refactor this one to use a smarter SQL query
function callee(i, cache?)
  if plural?(i)
    cache << SQL("child", WHERE multiple i)  ## it's the database records that
    return cache                             ## we cache, not the business logic itself
  elsif cache?
    ri = cache[i]                            ## SQL replaced by cache
    return some_result(ri)                   ## most logic untouched if possible
  else
    warn('callee should be prefetched')
    cache = callee([i])                      ## these two lines make the callee
    return callee(i, cache)                  ## equivalent to the original program
  end
end
```
