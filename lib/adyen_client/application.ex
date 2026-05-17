defmodule AdyenClient.Application do


  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {AdyenClient.RateLimiter, []},
      {AdyenClient.CircuitBreaker, []}
    ]

    opts = [strategy: :one_for_one, name: AdyenClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
