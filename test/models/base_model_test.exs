defmodule BaseModelTest do
  use ExUnit.Case, async: true

  defmodule TestModel do
    use TelegramBot.Models.BaseModel

    defmodule B do
      use TelegramBot.Models.BaseModel
      defstruct nested: nil
    end

    defmodule C do
      use TelegramBot.Models.BaseModel
      defstruct type: "C"
    end

    defmodule C2 do
      use TelegramBot.Models.BaseModel

      defmodule Deep do
        use TelegramBot.Models.BaseModel
        defstruct deep: nil
      end

      map :deep, Deep
      defstruct type: "C2", deep: nil
    end

    map :b, B
    map :c, %{"type" => "C"}, C
    map :c, %{"type" => "C2"}, C2

    defstruct a: 42, b: nil, c: nil
  end

  test "returns nil when input is nil" do
    assert TestModel.new(nil) == nil
  end

  test "simple mapping" do
    input = %{"b" => %{"nested" => true}}

    assert TestModel.new(input) == %TestModel{b: %TestModel.B{nested: true}}
  end

  test "defaults" do
    input = %{}

    assert TestModel.new(input) == %TestModel{a: 42, b: nil, c: nil}
  end

  test "conditional nesting" do
    input = %{"c" => %{"type" => "C"}}

    assert TestModel.new(input) == %TestModel{c: %TestModel.C{}}

    input = %{"c" => %{"type" => "C2"}}

    assert TestModel.new(input) == %TestModel{c: %TestModel.C2{}}
  end

  test "non matching conditional nesting" do
    input = %{"c" => %{"type" => "C3"}}

    model = TestModel.new(input)
    refute model.c[:__struct__]
    assert model.c == %{"type" => "C3"}
  end

  test "deep nesting" do
    input = %{"c" => %{"type" => "C2", "deep" => %{"deep" => true}}}
    c2 = TestModel.new(input).c
    assert c2 == %TestModel.C2{deep: %TestModel.C2.Deep{deep: true}}
  end
end
