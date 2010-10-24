$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

class ObjectTest < Test::Unit::TestCase

  def test_blank
    assert "         ".blank?
    assert nil.blank?
    assert [].blank?
    assert ({ }.blank?)
    assert !{ :a => 1}.blank?
    assert !"   dd".blank?
    assert ![1].blank?
  end

end
