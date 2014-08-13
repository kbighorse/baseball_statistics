require File.expand_path '../spec_helper.rb', __FILE__

describe Player do
  before(:all) do
    players_file = File.expand_path '../../data/Master-small.csv', __FILE__
    stats_file = File.expand_path '../../data/Batting-07-12.csv', __FILE__
    Player.load_data(players_file, stats_file)
  end

  describe 'when initialized with a CSV row' do
    before do
      headers = %w(playerID birthYear nameFirst nameLast)
      @row = CSV::Row.new(headers, ['aaronha01', 1934, 'Hank', 'Aaron'])
    end

    it 'should set the attributes properly' do
      player = Player.new(@row)
      assert_equal player.identifier, 'aaronha01'
      assert_equal player.birth_year, 1934
      assert_equal player.first_name, 'Hank'
      assert_equal player.last_name, 'Aaron'
    end
  end

  describe 'load_data' do
    describe 'with a well-formed CSV source file' do
      it 'should have the proper number of items' do
        assert_equal Player.count, 17945
      end

      it 'should be accessible by player ID' do
        assert_equal Player.find_by_identifier('abadan01').first_name, 'Andy'
        assert_equal Player.find_by_identifier('abadan01').last_name, 'Abad'
      end

      it 'should correctly calculate batting average' do
        player = Player.find_by_identifier 'bayja01'
        assert_equal 0.245, player.batting_average(2011).round(3)
      end
    end
  end

  describe 'when created' do
    it 'should have records' do
      assert Player.count > 0
    end

    it 'should have records' do
      assert Statistic.count > 0
    end
  end

  describe 'batter_with_most_improved_batting_average' do
    it 'successfully returns the right player' do
      assert_equal 'valenda01', Player.most_improved_average(2009, 2010).identifier
    end
  end

  describe 'hitting categories' do
    it 'returns the correct person id' do
      assert_equal 'cabremi01', Player.most_home_runs('AL', 2012).identifier
      assert_equal 'cabremi01', Player.top_batting_average('AL', 2012).identifier
      assert_equal 'cabremi01', Player.most_rbis('AL', 2012).identifier
      assert_equal 'suzukic01', Player.most_at_bats('AL', 2008).identifier
    end
  end

  describe 'triple_crown_winner' do
    describe 'when there is a triple crown winner for the league/year' do
      it 'returns the person_id of the winner' do
        assert_equal 'cabremi01', Player.triple_crown_winner('AL', 2012).identifier
        assert_nil Player.triple_crown_winner('NL', 2012)
      end
    end

    describe 'when there is no triple crown winner for the league that year' do
      it 'returns nil' do
        assert_nil Player.triple_crown_winner('NL', 2008)
        assert_nil Player.triple_crown_winner('AL', 2008)
        assert_nil Player.triple_crown_winner('AL', 2014)
      end
    end
  end

end
