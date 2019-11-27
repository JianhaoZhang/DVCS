require 'digest'
require "minitest/autorun"
require "open3"
require "fileutils"
require_relative "../general_utility.rb"
require_relative "../RevisionHistory.rb"
require_relative "../file_system.rb"

class GU
  include GeneralUtility
end

class Test_p1 < Minitest::Test
  
  def setup
  	@lca_hashes = { 
  		"Bool.hs" => '7c6763668e3b5b3f2632d614c232339513ff77c5',
  		"Array.hs" => '0ff7b2168226a1ca7b9414c71b917de4a828caec',
  		"King.hs" => '5aea037950732db4b040a10adda3687d22774c6b',
  		"Mark.hs" => '853b37b3d7c04c052826c811eb506c28e1097c77'
  	}
  	@src_hashes = { # Bool.hs changed, Mark.hs deleted, Whale.hs added
  		"Bool.hs" => '2c004cb28c2333737829ae13b702ce50f1bfe0ae', 
  		"Array.hs" => '0ff7b2168226a1ca7b9414c71b917de4a828caec',
  		"King.hs" => '5aea037950732db4b040a10adda3687d22774c6b',
  		"Whale.hs" => '33650303a24bbbd587edc44c55e87631bd64e32a'
  	}
  	@tgt_hashes = { # Bool.hs conflicts, Array.hs deleted, Whale.hs added conflicts
  		"Bool.hs" => '51d2f9e5a5322b166b201051eb4f84aead1217e5', 
  		"King.hs" => '5d4022ed630022a293c004107b5fb63cdf40714e',
  		"Whale.hs" => 'e706cf7f19a36d29949060accf5f558c0cb04aaa'
  	}

  end
  
  def test_get_deletions1
    gu = GU.new()
    assert_equal gu.get_deletions(@lca_hashes, @src_hashes), ["Mark.hs"]
  end

  def test_get_deletions2
    gu = GU.new()
   	assert_equal gu.get_deletions(@lca_hashes, @tgt_hashes), ["Array.hs","Mark.hs"]
  end
 
  def test_get_additions1
    gu = GU.new()
    src_additions = gu.get_additions(@lca_hashes, @src_hashes)
    assert_equal src_additions, [["Whale.hs", "33650303a24bbbd587edc44c55e87631bd64e32a"]]
  end

  def test_get_additions2
    gu = GU.new()
    tgt_additions = gu.get_additions(@lca_hashes, @tgt_hashes)
    assert_equal tgt_additions, [["Whale.hs", "e706cf7f19a36d29949060accf5f558c0cb04aaa"]]
  end

  def test_get_modifications1
  	gu = GU.new()
  	src_modifications = gu.get_modifications(@lca_hashes, @src_hashes)
  	assert_equal src_modifications, [["Bool.hs", "7c6763668e3b5b3f2632d614c232339513ff77c5", "2c004cb28c2333737829ae13b702ce50f1bfe0ae"]]
  end

  def test_get_modifications2
  	gu = GU.new()
  	tgt_modifications = gu.get_modifications(@lca_hashes, @tgt_hashes)
  	assert_equal tgt_modifications, [["Bool.hs", "7c6763668e3b5b3f2632d614c232339513ff77c5", "51d2f9e5a5322b166b201051eb4f84aead1217e5"], ["King.hs", "5aea037950732db4b040a10adda3687d22774c6b", "5d4022ed630022a293c004107b5fb63cdf40714e"]]
  end
  
  def test_get_conflicts
    
  end
  
end