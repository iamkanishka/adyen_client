defmodule AdyenClient.CircuitBreaker do
  @moduledoc """
  Simple circuit breaker protecting against Adyen API outages.

  States: `:closed` (normal) → `:open` (blocking) → `:half_open` (probing)

  Opens after `failure_threshold` consecutive failures.
  Moves to `:half_open` after `reset_timeout_ms`.
  Closes after one successful request in `:half_open`.
  """

  use GenServer

  @failure_threshold 5
  @reset_timeout_ms 30_000

  defstruct state: :closed,
            failures: 0,
            last_failure_at: nil,
            failure_threshold: @failure_threshold,
            reset_timeout_ms: @reset_timeout_ms

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Returns `:ok` if request may proceed, `{:error, :circuit_open}` if blocked."
  @spec allow?() :: :ok | {:error, :circuit_open}
  def allow?, do: GenServer.call(__MODULE__, :allow?)

  @doc "Record a successful request."
  @spec success() :: :ok
  def success, do: GenServer.cast(__MODULE__, :success)

  @doc "Record a failed request."
  @spec failure() :: :ok
  def failure, do: GenServer.cast(__MODULE__, :failure)

  @doc "Current circuit state."
  @spec state() :: :closed | :open | :half_open
  def state, do: GenServer.call(__MODULE__, :state)

  @impl true
  def init(opts) do
    threshold = Keyword.get(opts, :failure_threshold, @failure_threshold)
    timeout = Keyword.get(opts, :reset_timeout_ms, @reset_timeout_ms)

    {:ok,
     %__MODULE__{
       failure_threshold: threshold,
       reset_timeout_ms: timeout
     }}
  end

  @impl true
  def handle_call(:allow?, _from, state) do
    state = maybe_half_open(state)

    case state.state do
      :open -> {:reply, {:error, :circuit_open}, state}
      _ -> {:reply, :ok, state}
    end
  end

  def handle_call(:state, _from, state) do
    updated = maybe_half_open(state)
    {:reply, updated.state, updated}
  end

  @impl true
  def handle_cast(:success, state) do
    {:noreply, %{state | state: :closed, failures: 0, last_failure_at: nil}}
  end

  def handle_cast(:failure, state) do
    failures = state.failures + 1
    now = System.monotonic_time(:millisecond)

    new_state =
      if failures >= state.failure_threshold do
        %{state | state: :open, failures: failures, last_failure_at: now}
      else
        %{state | failures: failures, last_failure_at: now}
      end

    {:noreply, new_state}
  end

  defp maybe_half_open(%{state: :open, last_failure_at: t, reset_timeout_ms: timeout} = s) do
    now = System.monotonic_time(:millisecond)
    if now - t >= timeout, do: %{s | state: :half_open}, else: s
  end

  defp maybe_half_open(s), do: s
end
