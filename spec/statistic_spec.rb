require File.expand_path '../spec_helper.rb', __FILE__

describe Statistic do
  describe 'when initialized with a CSV row' do
    before do
      headers = %w(playerID yearID league teamID G AB R H 2B 3B HR RBI SB C)
      @row = CSV::Row.new(headers, [
        'abercre01',
        2008,
        'NL',
        'HOU',
        34,
        55,
        10,
        17,
        5,
        0,
        2,
        5,
        5,
        2])
    end

    it '#new' do
      stat = Statistic.new(@row)
      assert_equal stat.player_identifier, 'abercre01'
      assert_equal stat.year, 2008
      assert_equal stat.league, 'NL'
      assert_equal stat.team, 'HOU'
      assert_equal stat.at_bats, 55
      assert_equal stat.runs, 10
      assert_equal stat.hits, 17
      assert_equal stat.doubles, 5
      assert_equal stat.triples, 0
      assert_equal stat.home_runs, 2
      assert_equal stat.rbis, 5
    end

    it 'should calculate slugging_percentage correctly' do
      assert_equal 0.38733, Statistic.slugging_percentage('OAK', 2007).round(5)
    end
  end

  describe '.load_data' do
    before do
      players_file = File.expand_path '../../data/Master-small.csv', __FILE__
      stats_file = File.expand_path '../../data/Batting-07-12.csv', __FILE__
      Player.load_data(players_file, stats_file)
    end

    it 'should load correct number' do
      assert_equal Player.count, 17945
    end
  end

end
