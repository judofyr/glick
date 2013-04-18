class Glick
  include Math

  Player = Struct.new(:r, :rd, :vol) do
    DIFF = 173.7178
    BASE = 1500

    def self.initial
      from_pretty(BASE, 350)
    end

    def self.from_pretty(r, rd, vol = 0.06)
      new((r - BASE)/DIFF, rd/DIFF, vol)
    end

    def to_pretty
      [pretty_r, pretty_rd, vol]
    end

    def pretty_r
      r * DIFF + BASE
    end

    def pretty_rd
      rd * DIFF
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
    1/sqrt(1+(3*v.rd**2)/(PI**2))
  end

  def e(p1, p2)
    1/(1+exp(-g(p2) * (p1.r - p2.r)))
  end

  def compute(player, scores)
    if scores.empty?
      new_rd = sqrt(player.rd ** 2 + player.vol ** 2)
      return Player.new(player.r, new_rd, player.vol)
    end

    score = score(player, scores)
    v = v(player, scores.map { |p, _| p })
    delta = v * score

    a = oa = log(player.vol ** 2)
    rd = player.rd
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
    new_r = player.r + new_rd**2 * score

    Player.new(new_r, new_rd, new_vol)
  end

  class Round
    attr_reader :results

    def initialize(glick)
      @glick = glick
      @players = {}
      @scores = Hash.new { |h, k| h[k] = [] }
      @results = {}
    end

    def add_player(id, r, rd, vol = 0.06)
      @players[id] = Player.from_pretty(r, rd, vol)
    end

    def add_score(a, b, score = 1)
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

