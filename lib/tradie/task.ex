defmodule Tradie.Task do
  def create_task(work_ref, supervisor, fun) do
    caller = self
    task_ref = make_ref
    {:ok, pid} = Task.Supervisor.start_child(
      supervisor,
      __MODULE__, :run_task, [work_ref, task_ref, caller, fun]
    )
    task_ref
  end

  def run_task(work_ref, task_ref, caller, fun) do
    result = {work_ref, task_ref, do_run_task(fun)}
    send(caller, result)
  end

  defp do_run_task(fun) when is_function(fun), do: fun.()

  def receive_result(work_ref, task_ref) do
    receive do
      {^work_ref, ^task_ref, result} -> result
    end
  end
end
