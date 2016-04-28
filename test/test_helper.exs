ExUnit.start

Mix.Task.run "ecto.create", ~w(-r FactsVsEvents.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r FactsVsEvents.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(FactsVsEvents.Repo)

