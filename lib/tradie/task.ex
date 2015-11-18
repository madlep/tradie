defmodule Tradie.Task do
  defstruct [:work_ref, :task_ref, :caller, :fun]

  defmodule Result do
    defstruct [:work_ref, :task_ref, :result]
  end

  def create_task(work_ref, supervisor, fun) do
    task = %Tradie.Task{
      work_ref: work_ref,
      task_ref: make_ref,
      caller: self,
      fun: fun
    }

    {:ok, _pid} = Task.Supervisor.start_child( supervisor, __MODULE__, :run_task, [task])

    task
  end

  def run_task(%Tradie.Task{work_ref: work_ref, task_ref: task_ref, caller: caller, fun: fun}) do
    send(caller, %Result{
      work_ref: work_ref,
      task_ref: task_ref,
      result: do_run_task(fun)
    })
  end

  defp do_run_task(fun) when is_function(fun), do: fun.()

  def receive_result(%Tradie.Task{work_ref: work_ref, task_ref: task_ref}, tradie = %Tradie{timed_out: false, results: results}) do
    receive do
      %Result{work_ref: ^work_ref, task_ref: ^task_ref, result: result} ->
        %Tradie{tradie | results: [{:ok, result}|results]}
      {:timeout, ^work_ref} ->
        %Tradie{tradie | results: [{:error, :timed_out}|results], timed_out: true}
    end
  end

  def receive_result(%Tradie.Task{work_ref: work_ref, task_ref: task_ref}, tradie = %Tradie{timed_out: true, results: results}) do
    receive do
      %Result{work_ref: ^work_ref, task_ref: ^task_ref, result: result} ->
        %Tradie{tradie | results: [{:ok, result}|results]}
    after 0 ->
      %Tradie{tradie | results: [{:error, :timed_out}|results]}
    end
  end
end
