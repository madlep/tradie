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
      before do: {:shared, results: Tradie.await(tradie_tasks, 10) }
      let :expected_results, do: [{:ok, "foo"}, {:ok, "bar"}]

      it "runs tasks specified" do
        expect(shared.results) |> to eq(expected_results)
      end
    end

    context "timeout is reached" do
      context "and earlier task times out" do
        let :tradie_tasks, do: Tradie.async([
          TradieSpec.stub_task("foo", 1000),
          TradieSpec.stub_task("bar", 5)
        ])
        before do: {:shared, results: Tradie.await(tradie_tasks, 10) }
        let :expected_results, do: [{:error, :timed_out}, {:ok, "bar"}]

        it "returns timeout for earlier task, and result for later task" do
          expect(shared.results) |> to eq(expected_results)
        end
      end

      context "and later task times out" do
        let :tradie_tasks, do: Tradie.async([
          TradieSpec.stub_task("foo", 5),
          TradieSpec.stub_task("bar", 1000)
        ])
        before do: {:shared, results: Tradie.await(tradie_tasks, 10) }
        let :expected_results, do: [{:ok, "foo"}, {:error, :timed_out}]

        it "returns timeout for earlier task, and result for later task" do
          expect(shared.results) |> to eq(expected_results)
        end
      end
    end
  end
end
