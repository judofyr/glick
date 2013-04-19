require_relative 'helper'

class MiniTest::Unit::TestCase
  def setup
    @g = Glick.new
  end

  def test_example
    p1 = Glick::Player.new(1500, 200)
    p2 = Glick::Player.new(1400, 30)
    p3 = Glick::Player.new(1550, 100)
    p4 = Glick::Player.new(1700, 300)
    o = [p2, p3, p4]
    scores = [[p2, 1], [p3, 0], [p4, 0]]

    assert_equal 0, p1._r
    assert_in_delta 1.1513, p1._rd

    assert_in_delta 1.7785, @g.v(p1, o)

    assert_in_delta -0.4834, @g.delta(p1, scores)

    pl = @g.compute(p1, scores)
    assert_equal 1464, pl.r
    assert_equal 151, pl.rd
  end

  def test_round
    r = Glick::Round.new(@g)
    r.add_player(:a, 1500, 200, 0.06)
    r.add_player(:b, 1400, 30, 0.06)
    r.add_player(:c, 1550, 100, 0.06)
    r.add_player(:d, 1700, 300, 0.06)

    r.add_score(:a, :b)
    r.add_score(:c, :a)
    r.add_score(:d, :a)

    r.compute

    r, rd, vol = *r.results[:a]
    assert_equal 1464, r
    assert_equal 151, rd
  end
end

