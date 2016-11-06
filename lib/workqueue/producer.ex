defmodule Workqueue.Producer do
  use GenServer

  def start_link do
    IO.puts "starting producer"
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "init producer"
    send(self, {:produce})
    {:ok, %{name: 1}}
  end

  def handle_info({:produce}, job) do
    Workqueue.Queue.add_job(job)
    next = %{name: job.name + 1}
    Process.sleep(1000)
    if next.name <= 5 do
      send(self, {:produce})
    end
    {:noreply, next}
  end

end