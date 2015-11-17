ESpec.start

ESpec.configure fn(config) ->
  config.before fn ->
    # {:ok, hello: :world}
  end

  config.finally fn(_shared) ->

  end
end
