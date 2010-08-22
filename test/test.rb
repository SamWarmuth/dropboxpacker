require 'test/unit'
class BasicTests < Test::Unit::TestCase
  def test_didnt_break_class
    assert_equal(55.class, Fixnum)
  end
end

class EnglishTest < Test::Unit::TestCase
  [[1,2]].each do |pair|
    define_method("test_english_#{pair[0]}".to_sym) do
      assert_equal(pair[1], pair[0])
    end
  end
end