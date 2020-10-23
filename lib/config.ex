defmodule Formex.Config do
  def repo do
    Application.get_env(:formex, :repo)
  end
end
