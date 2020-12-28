defmodule Advent19Test do
  use ExUnit.Case
  doctest Advent19

  test "test incode problems still work" do
    assert Advent19.solve(2, 1) == 5290681
    assert Advent19.solve(2, 2) == 5741
    assert Advent19.solve(5, 1) == 16489636
    assert Advent19.solve(5, 2) == 9386583
  end
end
