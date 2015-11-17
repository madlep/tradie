defmodule Tradie do
  defstruct work_ref: nil,
            tasks: [],
            supervisor: nil

  def async(funs) do
    {:ok, supervisor} = Task.Supervisor.start_link(restart: :transient)
    tradie = %Tradie{work_ref: make_ref, supervisor: supervisor}
    start_tasks(tradie, funs)
  end

  defp start_tasks(tradie = %Tradie{work_ref: work_ref, supervisor: supervisor}, funs) do
    %Tradie{tradie | tasks: Enum.map(
      funs, &Tradie.Task.create_task(work_ref, supervisor, &1)
    )}
  end

  def await(%Tradie{work_ref: work_ref, tasks: tasks}, _timeout \\ 5000) do
    Enum.map(tasks, &Tradie.Task.receive_result(work_ref, &1))
  end
end
