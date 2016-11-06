defmodule WorkQueue.Worker do
  use GenServer

  def start_link(job) do
    GenServer.start_link(__MODULE__, job)
  end

  def init(state) do
    send(self, {:work})
    {:ok, state}
  end

  def handle_info({:work}, job) do
    IO.puts "Doing job #{job.name}..."
    if :rand.uniform() > 0.2 do
      raise "oops"
    else
      IO.puts "Job #{job.name} done!"
    end
    Workqueue.WorkerSupervisor.job_finished(self, job)
  end

end