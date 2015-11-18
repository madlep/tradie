defmodule Tradie.Mixfile do
  use Mix.Project

  def project do
    [app: :tradie,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     preferred_cli_env: [espec: :test],
     description: description,
     package: package
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:espec, "~> 0.8.5", only: :test}
    ]
  end

  defp description do
    """
    Execute multiple tasks in parallel, allowing retry for each task, and a global timeout. Based loosely on http://theerlangelist.com/article/beyond_taskasync.
    """
  end

  defp package do
    [
      maintainers: ["Julian Doherty"],
      licenses: ["MIT License"],
      links: %{
        "Github" => "https://github.com/madlep/tradie"
      }
    ]
  end
end
