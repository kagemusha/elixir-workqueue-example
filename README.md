# Workqueue

This is an example of a simple jobs queue - meant as an exercise in gettting used 
to OTP and supervisors trees.

## Installing and Running

Compile and run:

    workqueue> mix deps.compile
    workqueue> iex -S mix

## Modules

Note: as mentioned this is a practice app so is hopefully instructive, but should not be taken as gospel.  Suggested improvements are warmly welcomed :-)

The application has the following modules:

* workqueue: the top module implementing the `application` behavior as standard in mix projects
* producer: a `GenServer` to produce jobs to do
* queue: the jobs queue, though currently it just uses the `worker_supervisor` to create a `worker` passing in the job
* worker: the actual module that handles jobs
* worker_supervisor: the supervisor 

## Supervision Tree

The `workqueue` application module supervises the following children:

    children = [
      worker(Workqueue.Producer, []),
      worker(Workqueue.Queue, []),
      supervisor(Workqueue.WorkerSupervisor, [])
    ]

Its strategy is `:one_for_one` meaning any child process that crashes will be restarted.  If the queue actually had state, we might worry about how to store and retrieve it between restarts.

The `WorkerSupervisor` supervises `Worker` processes:

    def init(:ok) do
      children = [
        worker(WorkQueue.Worker, [], restart: :transient)
      ]
      supervise(children, strategy: :simple_one_for_one)
    end

`Worker` processes are started with a job after which, if they perform successfully, they notify the `WorkerSupervisor` they are done.  The latter then unceremoniously kills them off using [`Supervisor.terminate_child`](http://elixir-lang.org/docs/stable/elixir/Supervisor.html#terminate_child/2).  

`Worker` processes are programmed to fail at random.  When this happens, the `:transient` restart strategy means they will get restarted, importantly <i>with the same job</i>.  So `Worker` processes will continue to be created until the job gets done successfully.

Note that instead of creating and terminating `Worker` processes, it would generally be more efficient to create a worker pool.  Also, I am not sure whether in addition to terminating workers, they should be [deleted](http://elixir-lang.org/docs/stable/elixir/Supervisor.html#delete_child/2)

## Learn More

* [Elixir docs on supervisors and applications](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html)
* [A very simple Elixir OTP app from Jose Valim](https://howistart.org/posts/elixir/1)
* [A more involved OTP app modeling a casino](http://culttt.com/2016/09/21/building-casino-elixir/)
* [exq](https://github.com/akira/exq/blob/master/lib/exq/worker/supervisor.ex): a real Elixir jobs queue using Redis, modeled on Sidekiq/Resque
* [Elixir in Action](https://www.manning.com/books/elixir-in-action): good intro to OTP, though using earlier version of Elixir.  Look at the [githup repo](https://github.com/sasa1977/elixir-in-action) for up to date code examples
* [Little-Elixir-OTP-Guidebook](https://www.amazon.com/Little-Elixir-OTP-Guidebook/dp/1633430111): haven't read but has good reviews on Amazon
