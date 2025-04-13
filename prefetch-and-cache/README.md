## Prefetch & cache

This pattern can be used when a `caller -> callee` relationship involves
`N+1 queries`, `1` in the caller then `N` times `1` in the callee.

The refactoring keeps the `caller` mostly untouched (because it might have
complex business logic that you don't want to refactor). It extends the `callee`
with a plural form that uses the database in a smarter way and cache database
records for subsequent individual calls.

See also variants at the bottom of this page.

## Example

See the Ruby code: [before](./before.rb), [after](./after.rb) and [ideal](./ideal.rb)

The performance of `after.rb` is close to `ideal.rb` (that uses a `SQL JOIN`)
while it clearly involves less refactoring work and is already 20x faster.

```sh
$ time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/before.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m6.833s
user	0m0.499s
sys	0m0.142s

$ time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/after.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m0.364s
user	0m0.250s
sys	0m0.064s

$ time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/ideal.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m0.337s
user	0m0.245s
sys	0m0.058s
```

## Applicability

* IMPORTANT: the pattern is only usable when the list of ids yielding calls to
  `callee` can be known in advance. Either because the list is exactly known
  (e.g. no conditional logic), or because a superset is safe and its size not
  much bigger.

* IMPORTANT: the pattern is only valid if `callee` is a pure function without
  side effects, i.e. its results only depend on the input arguments and global
  software state is considered stable enough during the entire `caller`
  execution.

* The pattern is straightforward when the callee's first and only argument is a
  primary key that can be found easily on children records. It must be adapted
  otherwise.

## Before

```ruby
# we don't want to touch the loop code
function caller
  N = SQL(SELECT * FROM parent)
  for i in N
    # this call is be hidden in a lot of complex business logic
    # preventing a quick & safe refactoring that would remove the loop
    # completely
    callee(i)
end

# we may refactor this one and extend it with a plural variant
function callee(i)
  r = SQL(SELECT * FROM child WHERE i)
  return business_logic(r)
end
```

## After

```ruby
# we only touch two lines of code
function caller
  N = SQL(SELECT * FROM parent)
  cache = callee(N)                          ## prefetch & cache
  for i in N
    # this call is be hidden in a lot of complex business logic
    # preventing a quick & safe refactoring that would remove the loop
    # completely
    callee(i, cache)                         ## only one argument added
end

# refactored with overloading: a plural version builds the cache, a singular
# version uses it.
function callee(i, ?cache)
  if plural?(i)
    for each r in SQL(SELECT * FROM child WHERE key IN i)
      cache[key(r)] << r                     ## it's the database records that we cache
    return cache                             ## not the business logic itself
  elsif cache?(i)
    r = cache[i]                             ## SQL replaced by cache hit
    return business_logic(r)                 ## most logic untouched if possible
  else
    warn('callee should be prefetched')
    cache = callee([i])                      ## these two lines make the callee
    return callee(i, cache)                  ## equivalent to the original program
  end
end
```

## Variant 1: caching the callee's result

In the example above, children records are kept in a cache, typically per primary
key. The actual `callee`'s business logic for a given `i` is still done when the
individual call is made.

A variant exists where the callee's logic is executed at caching time instead.
We do not recommend it, since some caller's logic might actually skip some
record and the business logic execution is then unnecessary while possibly
costly. But if the refactoring is easier, it may prove an handy equivalent
choice.

```ruby
# refactored with overloading: a plural version builds the cache, a singular
# version uses it.
function callee(i, ?cache)
  if plural?(i)
    for each r in SQL(select * from child WHERE ... IN i)
      cache[key(r)] = business_logic(r)      ## we cache the result of logic instead
    return cache                             ## no longer the database record
  elsif cache?(i)
    return cache[i]                          ## SQL replaced by cache hit
  else
    warn('callee should be prefetched')
    cache = callee([i])                      ## these two lines make the callee
    return callee(i, cache)                  ## equivalent to the original program
  end
end
```
