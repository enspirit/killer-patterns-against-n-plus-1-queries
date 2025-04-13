## Memoize callee

This pattern can be used when a `caller -> callee` relationship involves
`N+1 queries`, `1` in the caller then `N` times `1` in the callee, while the
callee is re-executing the very same query over and over again.

The refactoring keeps both the `caller` and `callee` mostly untouched (because
they might have complex business logic that you don't want to refactor).

It just introduces a memorized version of `callee` to avoid hitting the database
server when not necessary.

## Example

See the Ruby code: [before](./before.rb), [after](./after.rb) and [ideal](./ideal.rb)

The performance of `after.rb` is still far from `ideal.rb` (that uses a `SQL JOIN`)
but involves very few refactoring work for decent results (6x faster on the example)

```sh
$ time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/before.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m6.812s
user	0m0.503s
sys	0m0.130s

$ time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/after.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m1.015s
user	0m0.280s
sys	0m0.069s

$ time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/ideal.rb > /dev/null
Running example with N=1000, SLOW=0.005

real	0m0.353s
user	0m0.248s
sys	0m0.063s
```

## Applicability

* The pattern only makes sense if `callee` is called multiple times with the
  very same arguments, e.g. if the child query has very few distinct records
  in comparison with the main iterated parent query.

* IMPORTANT: the pattern is only valid if `callee` is a pure function without
  side effects, i.e. its results only depend on the input arguments and global
  software state is considered stable enough during the entire `caller`
  execution.

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

# we don't want to touch this one either, but we might introduce a
# memoized version
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
  cache = {}                                 ## we somehow need a local cache
  for i in N
    memoized_callee(i, cache)                ## renamed + one argument added
end

# introduced as a memoization of `callee`
function memoized_callee(i, cache)
  if cache[i]
    return cache[i]
  else
    cache[i] = callee(i)
    return cache[i]
  end
end

# 100% untouched
function callee(i)
  r = SQL(SELECT * FROM child WHERE i)
  return business_logic(r)
end
```
