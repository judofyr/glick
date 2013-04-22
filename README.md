# Glick

Glick is a Ruby implementation of the [Glicko rating
system](http://en.wikipedia.org/wiki/Glicko_rating_system).

```
require 'glick'
g = Glick.new(:tau => 0.5)

p1 = Glick::Player.new(1500, 200)
p2 = Glick::Player.new(1400, 30)
p3 = Glick::Player.new(1550, 100)
p4 = Glick::Player.new(1700, 300)

# Glick#compute takes a a Player and a list of scores.
pl = g.compute(p1, [[p2, 1], [p3, 0], [p4, 0]])
pl.r  # => 1464
pl.rd # => 151
```

