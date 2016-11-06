defmodule Workqueue.WorkerSupervisor do
  use Supervisor

   def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
   end

  def init(:ok) do
    children = [
      worker(WorkQueue.Worker, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def new_worker(job) do
    Supervisor.start_child(Workqueue.WorkerSupervisor, [job])
  end

  def job_finished(pid, job) do
    IO.puts "Terminating self after #{job.name}\n\n"
    Supervisor.terminate_child(__MODULE__, pid)
  end

end