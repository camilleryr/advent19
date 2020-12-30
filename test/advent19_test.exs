defmodule Advent19Test do
  use ExUnit.Case
  doctest Advent19

  test "test incode problems still work" do
    assert Advent19.solve(2, 1) == 5290681
    assert Advent19.solve(2, 2) == 5741
    assert Advent19.solve(5, 1) == 16489636
    assert Advent19.solve(5, 2) == 9386583
    assert Advent19.solve(7, 1) == 262086
    assert Advent19.solve(7, 2) == 5371621
    assert Advent19.solve(9, 1) == 3409270027
    assert Advent19.solve(9, 2) == 82760
    assert Advent19.solve(11, 1) == 1686
    assert Advent19.solve(11, 2) == :ok
  end
end
