require 'csv'

class Player
  # Constants
  # ----------------------------------------------------------------------------
  MINIMUM_AT_BATS = 200
  AVG_MINIMUM_AT_BATS = 400

  # Class variable
  # ----------------------------------------------------------------------------
  @@players = {}

  # Attribute macros
  # ----------------------------------------------------------------------------
  attr_accessor :identifier, :birth_year, :first_name, :last_name

  # Class methods
  # ----------------------------------------------------------------------------
  def self.run(players_file, stats_file)
    Player.load_data(players_file, stats_file)
    mip = Player.most_improved_average(2009, 2010)
    slugging_percentage = Statistic.slugging_percentage('OAK', 2007)
    nl_triple_crown_winner = Player.triple_crown_winner('NL', 2012)
    al_triple_crown_winner = Player.triple_crown_winner('AL', 2012)

    puts "The player with the most improved batting average " <<
          "for the years 2009-2010 is #{mip}."
    puts "The slugging percentage for all Oakland players in 2007 is: " <<
          "#{slugging_percentage}."
    %w(NL AL).each do |league|
      [2011, 2012].each do |year|
        tcw = Player.triple_crown_winner(league, year)
        tcw_string = tcw ? tcw : "{No winner}"

        puts "The winner of the #{league} triple crown for the " <<
              "year #{year} is #{tcw_string}."
      end
    end
  end

  def self.load_data(players_file, stats_file)
    CSV.foreach(players_file, headers: true) do |row|
      next unless row['playerID']
      player = Player.new(row)

      @@players[player.identifier] = player
    end

    CSV.foreach(stats_file, headers: true) do |row|
      player = Player.find_by_identifier row['playerID']
      player.statistics << Statistic.new(row) if player
    end
  end

  def self.count
    @@players.size
  end

  def self.find_by_identifier(identifier)
    @@players[identifier]
  end

  def self.most_improved_average(from_year, to_year)
    mip = nil
    most_improvement = -1

    @@players.values.each do |player|
      improvement = player.improvement(from_year, to_year)

      if improvement > most_improvement
        most_improvement = improvement
        mip = player
      end
    end

    mip
  end

  def self.most_home_runs(league, year, min=MINIMUM_AT_BATS)
    top_player = nil
    most_home_runs = -1

    @@players.values.each do |player|
      home_runs = 0
      at_bats = 0

      player.statistics.each do |statistic|
        next unless statistic.league_and_year?(league, year)
        at_bats += statistic.at_bats
        home_runs += statistic.home_runs
      end

      if home_runs > most_home_runs && at_bats > min
        most_home_runs = home_runs
        top_player = player
      end
    end

    top_player
  end

  def self.most_at_bats(league, year)
    top_player = nil
    most_at_bats = -1

    @@players.values.each do |player|
      at_bats = 0

      player.statistics.each do |statistic|
        next unless statistic.league_and_year?(league, year)
        at_bats += statistic.at_bats
      end

      if at_bats > most_at_bats
        most_at_bats = at_bats
        top_player = player
      end
    end

    top_player
  end

  def self.top_batting_average(league, year, min=AVG_MINIMUM_AT_BATS)
    top_player = nil
    top_batting_average = -1

    @@players.values.each do |player|
      batting_average = 0.0
      at_bats = 0.0
      hits = 0.0

      player.statistics.each do |statistic|
        next unless statistic.league_and_year?(league, year)
        at_bats += statistic.at_bats
        hits += statistic.hits
      end

      batting_average = hits/at_bats
      if batting_average > top_batting_average && at_bats > min
        top_batting_average = batting_average
        top_player = player
      end
    end

    top_player
  end

  def self.most_rbis(league, year, min=MINIMUM_AT_BATS)
    top_player = nil
    most_rbis = -1

    @@players.values.each do |player|
      rbis = 0.0
      at_bats = 0

      player.statistics.each do |statistic|
        next unless statistic.league_and_year?(league, year)
        at_bats += statistic.at_bats
        rbis += statistic.rbis
      end

      if rbis > most_rbis && at_bats > min
        most_rbis = rbis
        top_player = player
      end
    end

    top_player
  end

  def self.triple_crown_winner(league, year, min=MINIMUM_AT_BATS)
    top_batting_average = Player.top_batting_average(league, year, AVG_MINIMUM_AT_BATS)
    most_home_runs      = Player.most_home_runs(league, year, min)
    most_rbis           = Player.most_rbis(league, year, min)

    if (top_batting_average == most_home_runs &&
        most_home_runs == most_rbis)
      return top_batting_average
    end

    nil
  end

  # Instance methods
  # ----------------------------------------------------------------------------
  def initialize(row)
    return unless row

    @statistics = Set.new

    self.identifier  = row['playerID']
    self.birth_year  = row['birthYear'].to_i
    self.first_name  = row['nameFirst']
    self.last_name   = row['nameLast']
  end

  def statistics
    @statistics
  end

  def batting_average(year)
    statistics.each do |statistic|
      if statistic.year == year && statistic.at_bats > MINIMUM_AT_BATS
        return statistic.batting_average
      end
    end

    0.0
  end

  def improvement(from_year, to_year)
    finish = batting_average(to_year)
    start = batting_average(from_year)
    return 0.0 unless start && finish
    finish - start
  end

  def to_s
    "#{first_name} #{last_name}"
  end

end
