defmodule Workqueue do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    IO.puts "starting workqueue"
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Workqueue.Worker.start_link(arg1, arg2, arg3)
      worker(Workqueue.Producer, []),
      worker(Workqueue.Queue, []),
      supervisor(Workqueue.WorkerSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Workqueue.Supervisor]
    IO.puts "starting children.."
    Supervisor.start_link(children, opts)
  end
end
