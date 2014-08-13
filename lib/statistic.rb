require 'csv'

class Statistic
  @@statistics = []

  # Attribute macros
  # ----------------------------------------------------------------------------
  attr_accessor :player_identifier, :year, :league, :team, :games, :at_bats,
                :runs, :hits, :doubles, :triples, :home_runs, :rbis

  # Class methods
  # ----------------------------------------------------------------------------
  def self.slugging_percentage(team, year)
    hits = 0
    doubles = 0
    triples = 0
    home_runs = 0
    at_bats = 0

    @@statistics.select do |statistic|
      next unless statistic.team_and_year?(team, year)
      hits      += statistic.hits.to_f
      doubles   += statistic.doubles.to_f
      triples   += statistic.triples.to_f
      home_runs += statistic.home_runs.to_f
      at_bats   += statistic.at_bats.to_f
    end

    singles = hits - doubles - triples - home_runs
    slugging_percentage =
      (singles + 2*doubles + 3*triples + 4*home_runs)/at_bats
  end

  def self.count
    @@statistics.size
  end

  # Instance methods
  # ----------------------------------------------------------------------------
  def initialize(row)
    return unless row

    self.player_identifier  = row['playerID']
    self.year        = row['yearID'].to_i
    self.league      = row['league']
    self.team        = row['teamID']
    self.games       = row['G'].to_i
    self.at_bats     = row['AB'].to_i
    self.runs        = row['R'].to_i
    self.hits        = row['H'].to_i
    self.doubles     = row['2B'].to_i
    self.triples     = row['3B'].to_i
    self.home_runs   = row['HR'].to_i
    self.rbis        = row['RBI'].to_i

    @@statistics << self
  end

  def to_s
    "year: #{self.year}, " <<
    "league: #{self.league}, " <<
    "at_bats: #{self.at_bats}; " <<
    "hits: #{self.hits}"
  end

  def batting_average
    return 0.0 if self.at_bats == 0
    self.hits.to_f/self.at_bats.to_f
  end

  def team_and_year?(team, year)
    self.team == team && self.year = year.to_i
  end

  def league_and_year?(league, year)
    result = self.league == league && self.year == year.to_i
    result
  end

end
