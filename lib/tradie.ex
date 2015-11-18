defmodule Tradie do
  defstruct work_ref: nil,
            tasks: [],
            supervisor: nil,
            timed_out: false,
            results: []

  alias Tradie.Task, as: TTask

  def async(funs) do
    {:ok, supervisor} = Task.Supervisor.start_link(restart: :transient)
    %Tradie{work_ref: make_ref, supervisor: supervisor}
    |> start_tasks(funs)
  end

  defp start_tasks(tradie = %Tradie{work_ref: work_ref, supervisor: supervisor}, funs) do
    %Tradie{tradie |
      tasks: funs |> Enum.map(&TTask.create_task(work_ref, supervisor, &1))
    }
  end

  def await(tradie = %Tradie{tasks: tasks, work_ref: work_ref}, timeout \\ 5000) do
    :timer.send_after(timeout, {:timeout, work_ref})
    final_tradie = tasks |> Enum.reduce(tradie, &(TTask.receive_result(&1, &2)))
    final_tradie.results |> Enum.reverse
  end
end
