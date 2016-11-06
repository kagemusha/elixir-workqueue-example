defmodule Workqueue.Queue do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "Starting queue. module: #{__MODULE__}"

    {:ok, []}
  end

  def start_pool do

  end

  def add_job(job) do
    IO.puts "add_job #{job.name}"
    GenServer.cast(__MODULE__, {:add_job, job})
  end

  def job_finished(job) do

  end

  def handle_cast({:add_job, job}, state) do
    IO.puts "adding job in queue"
    {:ok, _} = Workqueue.WorkerSupervisor.new_worker(job)
    {:noreply, state}
  end

  def handle_cast(_msg, state) do
    IO.puts "default cast"
    {:noreply, state}
  end

  def handle_info(_, state) do
    IO.puts "default handle info"
    {:noreply, state}
  end
end