defmodule TradieSpec do
  use ESpec

  defp stub_task(result, sleep_time \\ 0)
  defp stub_task(result, 0) do
    fn() ->
      result
    end
  end

  defp stub_task(result, sleep_time) do
    fn() ->
      :timer.sleep(sleep_time)
      result
    end
  end

  it "runs tasks specified" do
    tradie_tasks = Tradie.async([
      stub_task("foo"),
      stub_task("bar", 1)
    ])


    results = Tradie.await(tradie_tasks)
    expect(results).to eq([{:ok, "foo"}, {:ok, "bar"}])
  end
end
