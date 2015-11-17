defmodule TradieSpec do
  use ESpec

  def stub_task(result, sleep_time \\ 0)
  def stub_task(result, 0) do
    fn() ->
      result
    end
  end

  def stub_task(result, sleep_time) do
    fn() ->
      :timer.sleep(sleep_time)
      result
    end
  end

  describe "async/await" do
    context "when all tasks complete" do
      let :tradie_tasks, do: Tradie.async([
        TradieSpec.stub_task("foo"),
        TradieSpec.stub_task("bar", 1)
      ])
      before do: {:shared, results: Tradie.await(tradie_tasks) }
      let :expected_results, do: [{:ok, "foo"}, {:ok, "bar"}]

      it "runs tasks specified" do
        expect(shared.results) |> to eq(expected_results)
      end
    end

  end
end
