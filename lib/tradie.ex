defmodule Tradie do
  defstruct work_ref: nil,
            tasks: [],
            supervisor: nil

  def async(funs) do
    {:ok, supervisor} = Task.Supervisor.start_link(restart: :transient)
    %Tradie{work_ref: make_ref, supervisor: supervisor}
    |> start_tasks(funs)
  end

  defp start_tasks(tradie = %Tradie{work_ref: work_ref, supervisor: supervisor}, funs) do
    %Tradie{tradie |
      tasks: funs |> Enum.map(&Tradie.Task.create_task(work_ref, supervisor, &1))
    }
  end

  def await(%Tradie{tasks: tasks}, _timeout \\ 5000) do
    tasks |> Enum.map(&Tradie.Task.receive_result(&1))
  end
end
