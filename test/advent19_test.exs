defmodule Advent19Test do
  use ExUnit.Case
  doctest Advent19

  test "test incode problems still work" do
    assert Advent19.solve(2, 1) == 5_290_681
    assert Advent19.solve(2, 2) == 5741
    assert Advent19.solve(5, 1) == 16_489_636
    assert Advent19.solve(5, 2) == 9_386_583
    assert Advent19.solve(7, 1) == 262_086
    assert Advent19.solve(7, 2) == 5_371_621
    assert Advent19.solve(9, 1) == 3_409_270_027
    assert Advent19.solve(9, 2) == 82760
    assert Advent19.solve(11, 1) == 1686
    assert Advent19.solve(11, 2) == :ok
    assert Advent19.solve(13, 1) == 414
    assert Advent19.solve(13, 2) == 20183
  end
end
