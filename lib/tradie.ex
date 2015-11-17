defmodule Tradie do
  defstruct work_ref: nil,
            tasks: [],
            supervisor: nil

  def async(funs) do
    {:ok, supervisor} = Task.Supervisor.start_link(restart: :transient)

    %Tradie{
      work_ref: make_ref,
      tasks: [],
      supervisor: supervisor
    } |> start_tasks(funs)
  end

  defp start_tasks( %{work_ref: work_ref, supervisor: supervisor} = tradie, funs) do
    %Tradie{tradie | tasks: Enum.map(
      funs, &Tradie.Task.create_task(work_ref, supervisor, &1)
    )}
  end

  def await(tradie, _timeout \\ 5000) do
    accumulate_results(tradie, [])
  end

  defp accumulate_results(%Tradie{tasks: []}, results), do: :lists.reverse(results)

  defp accumulate_results(tradie = %Tradie{
    work_ref: work_ref,
    tasks: [task | tasks]
  }, results) do
    result = Tradie.Task.receive_result(work_ref, task)
    accumulate_results(%Tradie{tradie | tasks: tasks}, [result | results])
  end
end
