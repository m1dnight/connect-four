defmodule C4.Types do
  @moduledoc """
  Defines the types used in the game.
  """
  defmacro __using__(_opts) do
    quote do
      @type position :: {non_neg_integer(), non_neg_integer()}
      @type token :: :yellow | :red | :empty | :highlight
      @type player :: :yellow | :red | :empty | :highlight
      @type score :: number()
      @type depth :: non_neg_integer()
    end
  end
end
