defmodule AdyenClient.RateLimiter do
  @moduledoc """
  Token-bucket rate limiter to stay within Adyen's API rate limits.
  Defaults to 100 requests/second (configurable).
  """

  use GenServer

  @default_rate 100
  @default_burst 200
  @refill_interval_ms 1_000

  defstruct tokens: @default_burst,
            max_tokens: @default_burst,
            refill_rate: @default_rate,
            last_refill: nil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Acquire a token, blocking until one is available. Returns :ok."
  @spec acquire(non_neg_integer()) :: :ok
  def acquire(tokens \\ 1) do
    GenServer.call(__MODULE__, {:acquire, tokens}, 10_000)
  end

  @impl true
  def init(opts) do
    rate = Keyword.get(opts, :rate, @default_rate)
    burst = Keyword.get(opts, :burst, @default_burst)

    schedule_refill()

    {:ok,
     %__MODULE__{
       tokens: burst,
       max_tokens: burst,
       refill_rate: rate,
       last_refill: System.monotonic_time(:millisecond)
     }}
  end

  @impl true
  def handle_call({:acquire, n}, from, state) do
    state = refill(state)

    if state.tokens >= n do
      {:reply, :ok, %{state | tokens: state.tokens - n}}
    else
      # Queue the caller — retry after next refill
      Process.send_after(self(), {:retry, from, n}, @refill_interval_ms)
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:refill, state) do
    schedule_refill()
    {:noreply, refill(state)}
  end

  def handle_info({:retry, from, n}, state) do
    state = refill(state)

    if state.tokens >= n do
      GenServer.reply(from, :ok)
      {:noreply, %{state | tokens: state.tokens - n}}
    else
      Process.send_after(self(), {:retry, from, n}, @refill_interval_ms)
      {:noreply, state}
    end
  end

  defp refill(%__MODULE__{} = state) do
    now = System.monotonic_time(:millisecond)
    elapsed_ms = now - state.last_refill
    new_tokens = min(state.max_tokens, state.tokens + state.refill_rate * elapsed_ms / 1_000)
    %{state | tokens: new_tokens, last_refill: now}
  end

  defp schedule_refill do
    Process.send_after(self(), :refill, @refill_interval_ms)
  end
end
