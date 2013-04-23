# coding: utf-8

class Glick
  VERSION = "0.5.0".freeze

  class GlickError < StandardError; end

  include Math

  class Player
    DIFF = 173.7178
    BASE = 1500

    attr_reader :_r, :_rd, :vol

    def initialize(r = BASE, rd = 350, vol = 0.06)
      @_r = (r - BASE)/DIFF
      @_rd = rd/DIFF
      @vol = vol
    end

    def self._new(r, rd, vol)
      allocate.instance_eval do
        @_r = r
        @_rd = rd
        @vol = vol
        self
      end
    end

    def to_a
      [r, rd, vol]
    end

    def r
      _r * DIFF + BASE
    end

    def rd
      _rd * DIFF
    end

    def inspect
      "#<Glick::Player %.2f ± %.2f>" % [r, rd * 2]
    end
  end

  def initialize(settings = {})
    @tau = settings[:tau] || 0.5
  end

  def v(player, others)
    s = others.map do |other|
      e = e(player, other)
      (g(other) ** 2) * e * (1 - e)
    end

    s.reduce(:+) ** -1
  end

  def score(player, scores)
    s = scores.map do |other, score|
      g(other) * (score - e(player, other))
    end

    s.reduce(:+)
  end

  def delta(player, scores)
    v = v(player, scores.map { |p, _| p })
    v * score(player, scores)
  end

  def g(v)
    1/sqrt(1+(3*v._rd**2)/(PI**2))
  end

  def e(p1, p2)
    1/(1+exp(-g(p2) * (p1._r - p2._r)))
  end

  def compute(player, scores)
    if scores.empty?
      new_rd = sqrt(player._rd ** 2 + player.vol ** 2)
      return Player._new(player._r, new_rd, player.vol)
    end

    score = score(player, scores)
    v = v(player, scores.map { |p, _| p })
    delta = v * score

    a = oa = log(player.vol ** 2)
    rd = player._rd
    goal = 0.000001

    f = proc do |x|
      ((E**x * (delta ** 2 - rd ** 2 - v - E**x)) /
       (2 * (rd ** 2 + v + E**x) ** 2)) -
      (x - oa) / (@tau ** 2)
    end

    if delta ** 2 > rd ** 2 + v
      b = log(delta ** 2 - rd ** 2 - v)
    else
      k = 0
      begin
        k += 1
        b = oa - k * sqrt(@tau ** 2)
      end until f.(b) > 0
    end

    fa = f.(a)
    fb = f.(b)

    while (fb - fa).abs > goal
      c = a + (a - b) * fa / (fb - fa)
      fc = f.(c)

      if fc * fb < 0
        a = b
        fa = fb
      else
        fa = fa / 2
      end

      b = c
      fb = fc
    end

    new_vol = E ** (a / 2)
    pre_rd = sqrt(rd ** 2 + new_vol ** 2)

    new_rd = 1/sqrt(1/pre_rd**2 + 1/v)
    new_r = player._r + new_rd**2 * score

    Player._new(new_r, new_rd, new_vol)
  end

  class Round
    attr_reader :results

    def initialize(glick)
      @glick = glick
      @players = {}
      @scores = Hash.new { |h, k| h[k] = [] }
      @results = {}
    end

    def add_player(id, player)
      @players[id] = player
    end

    def add_score(a, b, score = 1)
      raise GlickError, "Unknown player: #{a.inspect}" unless @players[a]
      raise GlickError, "Unknown player: #{b.inspect}" unless @players[b]

      @scores[a] << [@players[b], (    score)]
      @scores[b] << [@players[a], (1 - score)]
    end

    def compute
      @players.each do |id, player|
        @results[id] = @glick.compute(player, @scores[id])
      end
      self
    end
  end
end

